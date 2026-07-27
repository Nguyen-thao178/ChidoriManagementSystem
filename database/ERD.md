# Chidori Coffee – Full ERD

Migration áp dụng: `migrations/V007_complete_order_schema_and_erd.sql`.

```mermaid
erDiagram
    USERS ||--o{ ORDERS : places
    USERS ||--|| LOYALTY_POINTS : owns
    USERS o|--o{ PROMOTIONS : creates
    USERS o|--o{ CONTACTS : account_for
    USERS o|--o{ SYSTEM_SETTINGS : updates
    USERS o|--o{ ORDER_STATUS_HISTORY : changes

    ORDERS ||--|{ ORDER_ITEMS : contains
    ORDERS ||--|{ PAYMENTS : paid_by
    ORDERS ||--|{ ORDER_STATUS_HISTORY : tracks

    PRODUCTS ||--o{ ORDER_ITEMS : purchased_as
    PRODUCTS ||--o{ PROMOTION_ITEMS : discounted_by
    PROMOTIONS ||--o{ PROMOTION_ITEMS : includes

    USERS {
        int id PK
        varchar username UK
        char password_hash
        nvarchar fullname
        varchar email UK
        varchar role
        datetime2 created_at
    }

    PRODUCTS {
        int id PK
        nvarchar name
        decimal price
        int stock
        int sold_count
        varchar barcode UK
        nvarchar category
    }

    ORDERS {
        int id PK
        int user_id FK
        decimal total_amount
        varchar status
        varchar order_type
        varchar payment_method
        decimal deposit_amount
        date pickup_date
        varchar pickup_status
    }

    ORDER_ITEMS {
        int id PK
        int order_id FK
        int product_id FK
        int quantity
        decimal price
    }

    PAYMENTS {
        bigint id PK
        int order_id FK
        varchar payment_stage
        varchar payment_method
        decimal amount
        varchar status
        varchar transaction_reference
    }

    ORDER_STATUS_HISTORY {
        bigint id PK
        int order_id FK
        int changed_by_id FK
        varchar old_status
        varchar new_status
        nvarchar note
        datetime2 changed_at
    }

    PROMOTIONS {
        int id PK
        int created_by_user_id FK
        nvarchar title
        int discount_percent
        date start_date
        date end_date
        varchar status
    }

    PROMOTION_ITEMS {
        int id PK
        int promotion_id FK
        int product_id FK
        int discount_percent
        date start_date
        date end_date
    }

    LOYALTY_POINTS {
        int id PK
        int user_id FK
        int points
        decimal total_spent
    }

    CONTACTS {
        int id PK
        int user_id FK
        nvarchar name
        varchar position
        varchar phone
        varchar email
    }

    SYSTEM_SETTINGS {
        int id PK
        int updated_by_user_id FK
        varchar setting_key UK
        nvarchar setting_value
    }
```

## Luồng dữ liệu chính

- Mỗi `order` thuộc một `user` và chứa nhiều `order_items`.
- Mỗi `order_item` tham chiếu chính xác một `product`.
- Một `promotion` áp dụng cho nhiều `products` thông qua `promotion_items`.
- Thanh toán trực tiếp tạo một dòng `payments` loại `full`.
- Đơn cọc tạo dòng `deposit`; khi khách nhận hàng, trigger tạo dòng `balance`.
- Mọi thay đổi trạng thái đơn được lưu trong `order_status_history`.
