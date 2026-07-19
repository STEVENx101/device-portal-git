package com.fintrex.deviceportal.config;

import java.util.List;
import java.util.Map;
import java.util.StringJoiner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class DataTableRepo {

    @Autowired
    NamedParameterJdbcTemplate jdbc;

    private final Pattern columnSelectorPattern =
            Pattern.compile("(?<=select)(.*?)(?=from\\s*(?![^(]*\\)))",
                    Pattern.CASE_INSENSITIVE | Pattern.DOTALL);

    private final Pattern removeAsPattern =
            Pattern.compile("\\bAS\\b\\s+[`']?(\\w+)[`']?", Pattern.CASE_INSENSITIVE);

    public DataTableResponse dataTable(DataTableRequest request, String sql, Object... args) {
        return getDataTable(request, sql, false, null, args);
    }

    public DataTableResponse dataTable(DataTableRequest request, String sql, Map<String, ?> paramMap) {
        return getDataTable(request, sql, true, paramMap);
    }

    private DataTableResponse getDataTable(
            DataTableRequest param,
            String qry,
            boolean isNamedParam,
            Map<String, ?> paramMap,
            Object... args) {

        Matcher matcher = columnSelectorPattern.matcher(qry);

        String cols;
        if (matcher.find()) {
            cols = matcher.group(0);
        } else {
            throw new RuntimeException("No Columns to Select");
        }

        // split ORDER BY if exists
        String baseQuery = qry;
        String orderClauseFromQuery = "";

        if (qry.toLowerCase().contains("order by")) {
            int orderIndex = qry.toLowerCase().lastIndexOf("order by");
            baseQuery = qry.substring(0, orderIndex);
            orderClauseFromQuery = qry.substring(orderIndex);
        }

        String tableAndConditions = baseQuery.split(Pattern.quote(cols))[1];

        // FINAL MAIN QUERY (no pagination)
        String innerQuery = "SELECT " + cols + tableAndConditions + " " + orderClauseFromQuery;

        DataTableResponse resp = new DataTableResponse();
        resp.setDraw(param.getDraw());

        // COUNT TOTAL
        String countQry = "SELECT COUNT(*) FROM (" + innerQuery + ") t";
        int totalCount = isNamedParam
                ? jdbc.queryForObject(countQry, paramMap, Integer.class)
                : jdbc.getJdbcTemplate().queryForObject(countQry, Integer.class, args);

        resp.setRecordsTotal(totalCount);

        // PAGE SIZE
        int limit = param.getLength();
        if (limit == -1) {
            limit = totalCount;
        }

        // ORDER BY
        List<DataTableRequest.Order> orders = param.getOrder();
        StringJoiner orderJoiner = new StringJoiner(",");

        if (orders != null) {
            for (DataTableRequest.Order order : orders) {
                orderJoiner.add((order.getColumn() + 1) + " " + order.getDir());
            }
        }

        String orderBy = orderJoiner.length() > 0
                ? " ORDER BY " + orderJoiner
                : "";

        // SEARCH
        String search = "";
        DataTableRequest.Search searchval = param.getSearch();

        if (searchval != null
                && searchval.getValue() != null
                && !searchval.getValue().isEmpty()) {

            String searchCondition =
                    " CONCAT_WS(''," +
                            removeAsPattern.matcher(cols).replaceAll("") +
                            ") REGEXP '" + searchval.getValue() + "'";

            String lowerBase = baseQuery.toLowerCase();

            if (lowerBase.contains("group by")) {
                search = " HAVING " + searchCondition;
            } else if (lowerBase.contains("where")) {
                search = " AND " + searchCondition;
            } else {
                search = " WHERE " + searchCondition;
            }
        }

        // FINAL PAGINATED QUERY  ✅ (THIS WAS NOT USED BEFORE)
        String finalQuery =
                "SELECT * FROM (" + innerQuery + ") t WHERE 1=1 "
                        + search
                        + orderBy
                        + " LIMIT " + param.getStart() + "," + limit;

        List<Map<String, Object>> data = isNamedParam
                ? jdbc.queryForList(finalQuery, paramMap)
                : jdbc.getJdbcTemplate().queryForList(finalQuery, args);

        resp.setData(data);

        // FILTER COUNT
        if (searchval != null
                && searchval.getValue() != null
                && !searchval.getValue().isEmpty()) {

            String filQry =
                    "SELECT COUNT(*) FROM (" +
                            "SELECT * FROM (" + innerQuery + ") t WHERE 1=1 " + search +
                            ") tb";

            int filtered = isNamedParam
                    ? jdbc.queryForObject(filQry, paramMap, Integer.class)
                    : jdbc.getJdbcTemplate().queryForObject(filQry, Integer.class, args);

            resp.setRecordsFiltered(filtered);
        } else {
            resp.setRecordsFiltered(totalCount);
        }

        return resp;
    }
}