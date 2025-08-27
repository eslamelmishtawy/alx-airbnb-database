# Normalization to 3NF

## Objective
Apply normalization to ensure the schema is in **Third Normal Form (3NF)** while keeping performance in mind.

---

## 1. First Normal Form (1NF)
**Rule:** Atomic attributes, no repeating groups, each field single-valued.
- All attributes are scalar (no arrays/lists). ✅
- Examples: `role`, `status`, and `payment_method` are single values enforced by ENUMs. ✅
- No repeating groups in any table. ✅

**Conclusion:** All tables satisfy 1NF. ✅

---

## 2. Second Normal Form (2NF)
**Rule:** No partial dependency of non-key attributes on part of a composite key (only relevant if composite PKs are used).
- All tables use single-attribute surrogate primary keys (UUIDs). ✅
- Therefore, no partial dependencies exist. ✅

**Conclusion:** All tables satisfy 2NF. ✅

---

## 3. Third Normal Form (3NF)
**Rule:** No transitive dependencies; non-key attributes must depend only on the key, the whole key, and nothing but the key.

### Table-by-Table Analysis

#### User(user_id, first_name, last_name, email, password_hash, phone_number, role, created_at)
- Non-key attributes depend only on `user_id`. ✅
- `email` is unique; no attribute depends on `email` except the key. ✅
- **3NF:** Satisfied.

#### Property(property_id, host_id, name, description, location, pricepernight, created_at, updated_at)
- All non-key attributes describe the property and depend only on `property_id`. ✅
- `host_id` is an FK; no transitive dependency introduced. ✅
- **3NF:** Satisfied.

#### Booking(booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at)
- Potential issue: `total_price` can be derived from `pricepernight * nights` (and dynamic pricing if present). This is a **derived attribute**.
  - **Option A (strict 3NF):** Remove `total_price` and compute at query time from `Property.pricepernight` and the number of nights. ✅
  - **Option B (pragmatic performance):** Keep `total_price` for immutability/auditing (e.g., price snapshots or discounts at booking time). If kept, enforce integrity with a trigger/check or application logic to ensure it matches computed business rules. ⚠️
- `status` is atomic and constrained to `{pending, confirmed, canceled}`. ✅
- **3NF:** Satisfied if using Option A or enforcing integrity in Option B.

#### Payment(payment_id, booking_id, amount, payment_date, payment_method)
- All non-key attributes depend only on `payment_id`. ✅
- `payment_method` is atomic; could be a lookup table if you want flexible methods (see recommendations). ✅
- **3NF:** Satisfied.

#### Review(review_id, property_id, user_id, rating, comment, created_at)
- All attributes depend only on `review_id`. `rating` is atomic and constrained 1–5. ✅
- **3NF:** Satisfied.

#### Message(message_id, sender_id, recipient_id, message_body, sent_at)
- All attributes depend only on `message_id`. ✅
- **3NF:** Satisfied.

---

## Recommended Adjustments (If Needed)

1. **Derived Field `Booking.total_price`**
   - **Strict 3NF:** remove from schema and compute via query:
     - `nights = DATEDIFF(day, start_date, end_date)`
     - `computed_total = nights * Property.pricepernight`
   - **If keeping for auditing/performance:** add integrity guard:
     - Database trigger or CHECK (if feasible) to assert `total_price >= 0` and aligns with agreed pricing logic (base price, taxes, discounts).

2. **Lookup Tables for Evolving Categorical Data**
   - Replace ENUMs with lookup tables if you anticipate changes without migrations:
     - `Role(role_id, role_name)`
     - `BookingStatus(status_id, name)`
     - `PaymentMethod(method_id, name)`
   - Benefits: extensibility, localized names, soft-deletes, metadata (e.g., display order).

3. **Normalize `location` (Optional)**
   - If queries rely on geographic parts, split `location` into structured fields:
     - `country`, `city`, `address_line`, `lat`, `lng` (with spatial index if supported).
   - Keeps 3NF and improves geospatial querying.

4. **Uniqueness & Business Rules**
   - `User.email` UNIQUE (already specified). ✅
   - (Optional) Prevent users from reviewing the same property multiple times:
     - Add unique composite index: `UNIQUE (property_id, user_id)` on `Review`.
   - (Optional) Prevent self-messaging:
     - Add CHECK `sender_id <> recipient_id` on `Message`.

5. **Indexing (Performance, Not Normalization)**
   - Foreign key columns: `host_id`, `property_id`, `user_id`, `booking_id`.
   - Frequent filters: `Booking.status`, `Payment.payment_date`, `Review.rating`.

---

## Final Verdict
With the minor note on `Booking.total_price`, the schema **meets 3NF**. You may keep `total_price` if you enforce integrity and treat it as a snapshot of the price at the time of booking; otherwise, remove it for strict normalization.