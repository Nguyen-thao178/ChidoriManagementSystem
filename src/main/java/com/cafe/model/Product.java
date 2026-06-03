package com.cafe.model;

public class Product {
    private int id;
    private String name;
    private double price;
    private String description;
    private int stock;
    private int soldCount;
    private String imageUrl;
    private String category;

    // constructors, getters, setters
    public Product() {}
    public Product(int id, String name, double price, String description, int stock, int soldCount, String imageUrl, String category) {
        this.id = id; this.name = name; this.price = price; this.description = description;
        this.stock = stock; this.soldCount = soldCount; this.imageUrl = imageUrl; this.category = category;
    }
    // getters/setters...
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }
    public int getSoldCount() { return soldCount; }
    public void setSoldCount(int soldCount) { this.soldCount = soldCount; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
}