package com.fintrex.deviceportal.config;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

public class DataTableRequest {

    private int draw;
    private List<Column> columns;
    private List<Order> order;
    private int start;
    private int length;
    private Search search;
    @JsonProperty(required = false)
    private Object data;

    public DataTableRequest(int draw, List<Column> columns, List<Order> order, int start, int length, Search search, Object data) {
        this.draw = draw;
        this.columns = columns;
        this.order = order;
        this.start = start;
        this.length = length;
        this.search = search;
        this.data = data;
    }

    public DataTableRequest() {
    }    

    public static class Search {

        private String value;
        private boolean regex;

        public Search(String value, boolean regex) {
            this.value = value;
            this.regex = regex;
        }

        /**
         * @return the value
         */
        public String getValue() {
            return value;
        }

        /**
         * @param value the value to set
         */
        public void setValue(String value) {
            this.value = value;
        }

        /**
         * @return the regex
         */
        public boolean isRegex() {
            return regex;
        }

        /**
         * @param regex the regex to set
         */
        public void setRegex(boolean regex) {
            this.regex = regex;
        }
    }

    public static class Column {

        private String data;
        private String name;
        private boolean searchable;
        private boolean orderable;
        private Search search;

        public Column(String data, String name, boolean searchable, boolean orderable, Search search) {
            this.data = data;
            this.name = name;
            this.searchable = searchable;
            this.orderable = orderable;
            this.search = search;
        }

        /**
         * @return the data
         */
        public String getData() {
            return data;
        }

        /**
         * @param data the data to set
         */
        public void setData(String data) {
            this.data = data;
        }

        /**
         * @return the name
         */
        public String getName() {
            return name;
        }

        /**
         * @param name the name to set
         */
        public void setName(String name) {
            this.name = name;
        }

        /**
         * @return the searchable
         */
        public boolean isSearchable() {
            return searchable;
        }

        /**
         * @param searchable the searchable to set
         */
        public void setSearchable(boolean searchable) {
            this.searchable = searchable;
        }

        /**
         * @return the orderable
         */
        public boolean isOrderable() {
            return orderable;
        }

        /**
         * @param orderable the orderable to set
         */
        public void setOrderable(boolean orderable) {
            this.orderable = orderable;
        }

        /**
         * @return the search
         */
        public Search getSearch() {
            return search;
        }

        /**
         * @param search the search to set
         */
        public void setSearch(Search search) {
            this.search = search;
        }

    }

    public static class Order {

        private int column;
        private String dir;

        public Order(int column, String dir) {
            this.column = column;
            this.dir = dir;
        }

        /**
         * @return the column
         */
        public int getColumn() {
            return column;
        }

        /**
         * @param column the column to set
         */
        public void setColumn(int column) {
            this.column = column;
        }

        /**
         * @return the dir
         */
        public String getDir() {
            return dir;
        }

        /**
         * @param dir the dir to set
         */
        public void setDir(String dir) {
            this.dir = dir;
        }

    }

    /**
     * @return the draw
     */
    public int getDraw() {
        return draw;
    }

    /**
     * @param draw the draw to set
     */
    public void setDraw(int draw) {
        this.draw = draw;
    }

    /**
     * @return the columns
     */
    public List<Column> getColumns() {
        return columns;
    }

    /**
     * @param columns the columns to set
     */
    public void setColumns(List<Column> columns) {
        this.columns = columns;
    }

    /**
     * @return the order
     */
    public List<Order> getOrder() {
        return order;
    }

    /**
     * @param order the order to set
     */
    public void setOrder(List<Order> order) {
        this.order = order;
    }

    /**
     * @return the start
     */
    public int getStart() {
        return start;
    }

    /**
     * @param start the start to set
     */
    public void setStart(int start) {
        this.start = start;
    }

    /**
     * @return the length
     */
    public int getLength() {
        return length;
    }

    /**
     * @param length the length to set
     */
    public void setLength(int length) {
        this.length = length;
    }

    /**
     * @return the search
     */
    public Search getSearch() {
        return search;
    }

    /**
     * @param search the search to set
     */
    public void setSearch(Search search) {
        this.search = search;
    }

    /**
     * @return the data
     */
    public Object getData() {
        return data;
    }

    /**
     * @param data the data to set
     */
    public void setData(Object data) {
        this.data = data;
    }
    
    
    
    
}
