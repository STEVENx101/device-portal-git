package com.fintrex.deviceportal.service;

import com.itextpdf.io.image.ImageDataFactory;
import com.itextpdf.kernel.colors.Color;
import com.itextpdf.kernel.colors.ColorConstants;
import com.itextpdf.kernel.colors.DeviceRgb;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.borders.Border;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Image;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.element.Text;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;
import com.itextpdf.layout.properties.VerticalAlignment;
import org.apache.poi.xwpf.usermodel.*;
import org.openxmlformats.schemas.drawingml.x2006.picture.CTPicture;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigInteger;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;

/**
 * Unified pure-Java DOCX-to-PDF and filled-DOCX generator supporting all three
 * print modes (FULL_DOCUMENT, DOC_FORMAT, PRE_PRINTED) with split-run placeholder
 * normalization.
 */
@Component
public class LetterDocumentEngine {

    private static final Logger log = LoggerFactory.getLogger(LetterDocumentEngine.class);

    public enum RenderMode {
        FULL_DOCUMENT,
        DOC_FORMAT,
        PRE_PRINTED;

        public static RenderMode fromString(String raw) {
            if (raw == null) return FULL_DOCUMENT;
            return switch (raw.trim()) {
                case "Doc_Format", "DOC_FORMAT" -> DOC_FORMAT;
                case "Pre_Printed_Document", "PRE_PRINTED" -> PRE_PRINTED;
                default -> FULL_DOCUMENT;
            };
        }
    }

    public byte[] generatePdf(Path templatePath, Map<String, String> placeholders, RenderMode mode, int baseFontSize) {
        List<Map.Entry<String, String>> sortedPlaceholders = sortByKeyLengthDesc(placeholders);

        try (InputStream fis = Files.newInputStream(templatePath);
             ByteArrayOutputStream baos = new ByteArrayOutputStream();
             XWPFDocument document = new XWPFDocument(fis);
             PdfWriter writer = new PdfWriter(baos);
             PdfDocument pdfDocument = new PdfDocument(writer);
             Document pdfDoc = new Document(pdfDocument)) {

            boolean hasContent = false;
            for (IBodyElement element : document.getBodyElements()) {
                if (element.getElementType() == BodyElementType.PARAGRAPH) {
                    processParagraph((XWPFParagraph) element, sortedPlaceholders, mode, pdfDoc, baseFontSize);
                    hasContent = true;
                } else if (element.getElementType() == BodyElementType.TABLE) {
                    processTable((XWPFTable) element, sortedPlaceholders, mode, pdfDoc, baseFontSize);
                    hasContent = true;
                }
            }

            if (!hasContent) {
                pdfDoc.add(new Paragraph("Document template is empty."));
            }

            pdfDoc.close();
            return baos.toByteArray();
        } catch (IOException e) {
            throw new RuntimeException("Failed to generate PDF from template " + templatePath.getFileName() + ": " + e.getMessage(), e);
        }
    }

    public byte[] generateDocx(Path templatePath, Map<String, String> placeholders, RenderMode mode) {
        List<Map.Entry<String, String>> sortedPlaceholders = sortByKeyLengthDesc(placeholders);

        try (InputStream fis = Files.newInputStream(templatePath);
             ByteArrayOutputStream baos = new ByteArrayOutputStream();
             XWPFDocument document = new XWPFDocument(fis)) {

            for (XWPFParagraph p : document.getParagraphs()) {
                replacePlaceholdersInParagraphRuns(p, sortedPlaceholders, mode);
            }
            for (XWPFTable table : document.getTables()) {
                for (XWPFTableRow row : table.getRows()) {
                    for (XWPFTableCell cell : row.getTableCells()) {
                        for (XWPFParagraph p : cell.getParagraphs()) {
                            replacePlaceholdersInParagraphRuns(p, sortedPlaceholders, mode);
                        }
                    }
                }
            }
            document.write(baos);
            return baos.toByteArray();
        } catch (IOException e) {
            throw new RuntimeException("Failed to generate DOCX from template " + templatePath.getFileName() + ": " + e.getMessage(), e);
        }
    }

    private void processParagraph(
            XWPFParagraph paragraph,
            List<Map.Entry<String, String>> sortedPlaceholders,
            RenderMode mode,
            Document pdfDoc,
            int baseFontSize) {

        Paragraph pdfParagraph = new Paragraph();
        pdfParagraph.setTextAlignment(mapAlignment(paragraph.getAlignment(), TextAlignment.JUSTIFIED));

        // Normalize split runs if a placeholder spans across adjacent runs
        consolidateSplitPlaceholderRuns(paragraph, sortedPlaceholders);

        for (XWPFRun run : paragraph.getRuns()) {
            // Embedded images
            for (XWPFPicture picture : run.getEmbeddedPictures()) {
                try {
                    byte[] imageBytes = picture.getPictureData().getData();
                    CTPicture ctPicture = picture.getCTPicture();
                    long widthEMU = ctPicture.getSpPr().getXfrm().getExt().getCx();
                    long heightEMU = ctPicture.getSpPr().getXfrm().getExt().getCy();

                    Image img = new Image(ImageDataFactory.create(imageBytes));
                    img.setWidth(widthEMU / 12700f);
                    img.setHeight(heightEMU / 12700f);
                    if (mode == RenderMode.PRE_PRINTED) {
                        img.setOpacity(0f);
                    }
                    pdfDoc.add(img);
                } catch (Exception e) {
                    log.debug("Skipping embedded image sizing: {}", e.getMessage());
                }
            }

            String text = run.getText(0);
            if (text == null) {
                continue;
            }

            List<TextSegment> segments = splitAndReplace(text, sortedPlaceholders);
            for (TextSegment seg : segments) {
                Text pdfText = buildPdfText(seg.text, seg.isPlaceholder, run, mode, baseFontSize, false);
                pdfParagraph.add(pdfText);
            }
        }

        pdfDoc.add(pdfParagraph);
    }

    private void processTable(
            XWPFTable table,
            List<Map.Entry<String, String>> sortedPlaceholders,
            RenderMode mode,
            Document pdfDoc,
            int baseFontSize) {

        if (table.getNumberOfRows() == 0) {
            return;
        }

        XWPFTableRow firstRow = table.getRow(0);
        int numColumns = firstRow.getTableCells().size();
        if (numColumns == 0) {
            return;
        }

        float[] colRel = new float[numColumns];
        float totalRaw = 0f;
        for (int i = 0; i < numColumns; i++) {
            XWPFTableCell cell = firstRow.getCell(i);
            long raw = extractCellWidthDxa(cell);
            if (raw <= 0) raw = 1L;
            colRel[i] = raw;
            totalRaw += raw;
        }

        float[] colPercents = new float[numColumns];
        for (int i = 0; i < numColumns; i++) {
            colPercents[i] = (colRel[i] / totalRaw) * 100f;
        }

        Table pdfTable = new Table(UnitValue.createPercentArray(colPercents)).useAllAvailableWidth();
        boolean tableHasBorders = hasTableBorders(table);

        for (XWPFTableRow row : table.getRows()) {
            float rowHeightPoints = extractRowHeightPoints(row);

            for (XWPFTableCell cell : row.getTableCells()) {
                Paragraph cellParagraph = new Paragraph();
                TextAlignment alignment = TextAlignment.LEFT;

                List<XWPFParagraph> cellParagraphs = cell.getParagraphs();
                for (int pIdx = 0; pIdx < cellParagraphs.size(); pIdx++) {
                    XWPFParagraph paragraph = cellParagraphs.get(pIdx);
                    consolidateSplitPlaceholderRuns(paragraph, sortedPlaceholders);

                    for (XWPFRun run : paragraph.getRuns()) {
                        String text = run.getText(0);
                        if (text == null) continue;
                        List<TextSegment> segments = splitAndReplace(text, sortedPlaceholders);
                        for (TextSegment seg : segments) {
                            cellParagraph.add(buildPdfText(seg.text, seg.isPlaceholder, run, mode, baseFontSize, true));
                        }
                    }

                    if (pIdx < cellParagraphs.size() - 1) {
                        cellParagraph.add("\n");
                    }
                    alignment = mapAlignment(paragraph.getAlignment(), TextAlignment.LEFT);
                }

                cellParagraph.setTextAlignment(alignment);
                Cell pdfCell = new Cell().add(cellParagraph);
                if (rowHeightPoints > 0) {
                    pdfCell.setMinHeight(rowHeightPoints);
                }

                try {
                    XWPFTableCell.XWPFVertAlign vert = cell.getVerticalAlignment();
                    if (vert != null) {
                        switch (vert) {
                            case CENTER -> pdfCell.setVerticalAlignment(VerticalAlignment.MIDDLE);
                            case TOP -> pdfCell.setVerticalAlignment(VerticalAlignment.TOP);
                            case BOTTOM -> pdfCell.setVerticalAlignment(VerticalAlignment.BOTTOM);
                        }
                    }
                } catch (Exception ignored) {
                }

                if (!tableHasBorders || mode == RenderMode.PRE_PRINTED) {
                    pdfCell.setBorder(Border.NO_BORDER);
                }

                long widthDxa = extractCellWidthDxa(cell);
                if (widthDxa > 0) {
                    pdfCell.setMinWidth(widthDxa / 20f);
                }

                pdfTable.addCell(pdfCell);
            }
        }

        pdfDoc.add(pdfTable);
    }

    private Text buildPdfText(
            String text,
            boolean isPlaceholder,
            XWPFRun run,
            RenderMode mode,
            int baseFontSize,
            boolean inTable) {

        Text pdfText = new Text(text);

        // Color logic by mode
        if (mode == RenderMode.PRE_PRINTED) {
            pdfText.setFontColor(isPlaceholder ? ColorConstants.BLACK : ColorConstants.WHITE);
        } else if (mode == RenderMode.DOC_FORMAT) {
            if (isPlaceholder) {
                pdfText.setFontColor(ColorConstants.WHITE);
            } else {
                applyRunColor(pdfText, run);
            }
        } else {
            applyRunColor(pdfText, run);
        }

        // Font size rules matching legacy letter templates
        if (!inTable && text.contains("Sale of Vehicle")) {
            pdfText.setFontSize(22f).setBold();
        } else if (!inTable && text.contains("Details of Vehicle")) {
            pdfText.setFontSize(11f).setBold();
        } else if (!inTable && text.contains("Rs.100 Stamp to be placed")) {
            pdfText.setFontSize(6f).setBold();
        } else if (!inTable && text.contains("DUPLICATE") && text.contains("LETTER OF OFFER")) {
            pdfText.setFontSize(9f).setBold();
        } else if (isPlaceholder) {
            pdfText.setFontSize(inTable ? (float) baseFontSize : 9f);
        } else {
            pdfText.setFontSize((float) baseFontSize);
        }

        if (run.isBold()) {
            pdfText.setBold();
        }
        if (run.isItalic()) {
            pdfText.setItalic();
        }
        if (run.getUnderline() != UnderlinePatterns.NONE) {
            pdfText.setUnderline();
        }
        return pdfText;
    }

    private void applyRunColor(Text pdfText, XWPFRun run) {
        String hex = run.getColor();
        if (hex != null && hex.length() == 6) {
            try {
                Color color = new DeviceRgb(
                        Integer.parseInt(hex.substring(0, 2), 16),
                        Integer.parseInt(hex.substring(2, 4), 16),
                        Integer.parseInt(hex.substring(4, 6), 16));
                pdfText.setFontColor(color);
            } catch (NumberFormatException ignored) {
            }
        }
    }

    /**
     * If Word fragmented a placeholder key across multiple adjacent runs (e.g. "cFull" + "Name"),
     * merge the text into the first run of the paragraph while preserving its styling.
     */
    private void consolidateSplitPlaceholderRuns(XWPFParagraph paragraph, List<Map.Entry<String, String>> sortedPlaceholders) {
        List<XWPFRun> runs = paragraph.getRuns();
        if (runs == null || runs.size() <= 1) {
            return;
        }
        String fullText = paragraph.getText();
        if (fullText == null || fullText.isEmpty()) {
            return;
        }

        boolean needsMerge = false;
        for (Map.Entry<String, String> entry : sortedPlaceholders) {
            String key = entry.getKey();
            if (fullText.contains(key)) {
                boolean foundInSingleRun = false;
                for (XWPFRun r : runs) {
                    String rt = r.getText(0);
                    if (rt != null && rt.contains(key)) {
                        foundInSingleRun = true;
                        break;
                    }
                }
                if (!foundInSingleRun) {
                    needsMerge = true;
                    break;
                }
            }
        }

        if (!needsMerge) {
            return;
        }

        // Only merge runs that do not carry embedded pictures
        boolean hasPictures = runs.stream().anyMatch(r -> !r.getEmbeddedPictures().isEmpty());
        if (hasPictures) {
            return;
        }

        XWPFRun first = runs.get(0);
        first.setText(fullText, 0);
        for (int i = runs.size() - 1; i >= 1; i--) {
            paragraph.removeRun(i);
        }
    }

    private void replacePlaceholdersInParagraphRuns(
            XWPFParagraph paragraph,
            List<Map.Entry<String, String>> sortedPlaceholders,
            RenderMode mode) {

        consolidateSplitPlaceholderRuns(paragraph, sortedPlaceholders);
        for (XWPFRun run : paragraph.getRuns()) {
            String text = run.getText(0);
            if (text == null || text.isEmpty()) continue;

            boolean replaced = false;
            String updated = text;
            for (Map.Entry<String, String> entry : sortedPlaceholders) {
                if (updated.contains(entry.getKey())) {
                    String replacement = (mode == RenderMode.DOC_FORMAT) ? " ".repeat(Math.max(4, entry.getKey().length())) : entry.getValue();
                    updated = updated.replace(entry.getKey(), replacement);
                    replaced = true;
                }
            }
            if (replaced) {
                run.setText(updated, 0);
            } else if (mode == RenderMode.PRE_PRINTED) {
                run.setColor("FFFFFF");
            }
        }
    }

    private record TextSegment(String text, boolean isPlaceholder) {}

    private List<TextSegment> splitAndReplace(String text, List<Map.Entry<String, String>> sortedPlaceholders) {
        List<TextSegment> current = new ArrayList<>();
        current.add(new TextSegment(text, false));

        for (Map.Entry<String, String> entry : sortedPlaceholders) {
            String key = entry.getKey();
            String val = entry.getValue() != null ? entry.getValue() : "";
            List<TextSegment> next = new ArrayList<>();
            for (TextSegment seg : current) {
                if (seg.isPlaceholder || !seg.text.contains(key)) {
                    next.add(seg);
                    continue;
                }
                String remaining = seg.text;
                int idx;
                while ((idx = remaining.indexOf(key)) >= 0) {
                    if (idx > 0) {
                        next.add(new TextSegment(remaining.substring(0, idx), false));
                    }
                    next.add(new TextSegment(val, true));
                    remaining = remaining.substring(idx + key.length());
                }
                if (!remaining.isEmpty()) {
                    next.add(new TextSegment(remaining, false));
                }
            }
            current = next;
        }
        return current;
    }

    private List<Map.Entry<String, String>> sortByKeyLengthDesc(Map<String, String> placeholders) {
        List<Map.Entry<String, String>> list = new ArrayList<>(placeholders.entrySet());
        list.sort((a, b) -> Integer.compare(b.getKey().length(), a.getKey().length()));
        return list;
    }

    private TextAlignment mapAlignment(ParagraphAlignment pa, TextAlignment fallback) {
        if (pa == null) return fallback;
        return switch (pa) {
            case LEFT -> TextAlignment.LEFT;
            case CENTER -> TextAlignment.CENTER;
            case RIGHT -> TextAlignment.RIGHT;
            case BOTH -> TextAlignment.JUSTIFIED;
            default -> fallback;
        };
    }

    private boolean hasTableBorders(XWPFTable table) {
        try {
            return table.getCTTbl() != null
                    && table.getCTTbl().getTblPr() != null
                    && table.getCTTbl().getTblPr().getTblBorders() != null;
        } catch (Exception e) {
            return false;
        }
    }

    private long extractCellWidthDxa(XWPFTableCell cell) {
        try {
            if (cell != null && cell.getCTTc() != null
                    && cell.getCTTc().getTcPr() != null
                    && cell.getCTTc().getTcPr().getTcW() != null) {
                return Long.parseLong(cell.getCTTc().getTcPr().getTcW().getW().toString());
            }
        } catch (Exception ignored) {
        }
        return 0L;
    }

    private float extractRowHeightPoints(XWPFTableRow row) {
        try {
            if (row.getCtRow() != null && row.getCtRow().getTrPr() != null
                    && row.getCtRow().getTrPr().sizeOfTrHeightArray() > 0) {
                BigInteger val = (BigInteger) row.getCtRow().getTrPr().getTrHeightArray(0).getVal();
                if (val != null) {
                    return val.floatValue() / 20f;
                }
            }
        } catch (Exception ignored) {
        }
        return -1f;
    }
}
