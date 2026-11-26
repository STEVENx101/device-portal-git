package com.fintrex.deviceportal.service;

import java.math.BigDecimal;
import java.math.RoundingMode;

public final class NumberToWordsConverter {

    private static final String[] UNITS = {
            "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
            "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"
    };

    private static final String[] TENS = {
            "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
    };

    private static final String[] THOUSANDS = {
            "", "Thousand", "Million", "Billion", "Trillion"
    };

    private NumberToWordsConverter() {
    }

    public static String convert(String rawNumeric) {
        if (rawNumeric == null || rawNumeric.isBlank()) {
            return "";
        }
        try {
            BigDecimal bd = new BigDecimal(rawNumeric.replace(",", "").trim());
            return convert(bd);
        } catch (NumberFormatException e) {
            return "";
        }
    }

    public static String convert(BigDecimal amount) {
        if (amount == null) {
            return "";
        }
        amount = amount.setScale(2, RoundingMode.HALF_UP);
        if (amount.compareTo(BigDecimal.ZERO) == 0) {
            return "Zero";
        }
        long integerPart = amount.longValue();
        int cents = amount.remainder(BigDecimal.ONE).movePointRight(2).abs().intValue();

        StringBuilder sb = new StringBuilder();
        if (integerPart < 0) {
            sb.append("Minus ");
            integerPart = Math.abs(integerPart);
        }
        sb.append(convertIntegerToWords(integerPart));
        if (cents > 0) {
            sb.append(" and ").append(convertIntegerToWords(cents)).append(" Cents");
        }
        return sb.toString().trim();
    }

    private static String convertIntegerToWords(long number) {
        if (number == 0) {
            return "Zero";
        }
        int groupIndex = 0;
        StringBuilder result = new StringBuilder();
        while (number > 0) {
            int chunk = (int) (number % 1000);
            if (chunk != 0) {
                String words = convertHundredsToWords(chunk);
                if (!THOUSANDS[groupIndex].isEmpty()) {
                    words = words + " " + THOUSANDS[groupIndex];
                }
                if (result.length() > 0) {
                    result.insert(0, words + " ");
                } else {
                    result.append(words);
                }
            }
            number /= 1000;
            groupIndex++;
        }
        return result.toString().trim();
    }

    private static String convertHundredsToWords(int number) {
        if (number < 20) {
            return UNITS[number];
        }
        if (number < 100) {
            return (TENS[number / 10] + " " + UNITS[number % 10]).trim();
        }
        String prefix = UNITS[number / 100] + " Hundred";
        int rem = number % 100;
        return rem == 0 ? prefix : prefix + " and " + convertHundredsToWords(rem);
    }
}
