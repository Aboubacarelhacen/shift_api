# Shift Management API (Rails 7)

## Overview

API-only Rails 7 backend for a Shift Management application with JWT auth (Devise + devise-jwt), PostgreSQL, role-based access (ADMIN, MANAGER, EMPLOYEE), shift assignment validation, and swap workflow.

## Stack

- Ruby 3.2+/3.3
- Rails 7 API-only
- PostgreSQL
- Devise + devise-jwt
- rack-cors
- kaminari (pagination)
- ransack (search/filter)
- active_model_serializers
- rswag (OpenAPI/Swagger docs)
- RSpec + FactoryBot + Faker

## Setup

1. Copy `.env.example` to `.env` and set values.
2. Install dependencies:

```bash
bundle install
```

3. Prepare DB (ensure PostgreSQL running and user exists):

```bash
bin/rails db:setup
```

4. Seed demo data:

```bash
bin/rails db:seed
```

5. Run server:

```bash
bin/rails server
```

## Auth

Use `Authorization: Bearer <JWT>` header.

Endpoints:

- POST `/auth/register` -> { token, user }
- POST `/auth/login` -> { token, user }
- DELETE `/auth/logout`
- GET `/auth/me` -> { user }

## Roles

- ADMIN: full access
- MANAGER: manage shifts, assignments, employees, approve swaps
- EMPLOYEE: own profile, assigned shifts, create swap requests

## Core Endpoints

Employees:

- GET `/employees?q[first_name_or_email_cont]=...&page=1&per=10`
- POST `/employees`
- GET `/employees/:id`
- PUT `/employees/:id`
- DELETE `/employees/:id` (soft delete: active=false)
- GET `/employees/:id/availability`
- PUT `/employees/:id/availability` bulk upsert `[ {weekday,start_time,end_time}, ... ]`

Shifts:

- GET `/shifts?date_from=YYYY-MM-DD&date_to=YYYY-MM-DD&team=...&role=...`
- POST `/shifts`
- GET `/shifts/:id`
- PUT `/shifts/:id`
- DELETE `/shifts/:id`
- POST `/shifts/:id/assignments { employee_id, override? }`
- DELETE `/shifts/:id/assignments/:employee_id`

Swap Requests:

- GET `/swap-requests?status=PENDING`
- POST `/swap-requests { shift_id, to_employee_id, reason }`
- GET `/swap-requests/:id`
- POST `/swap-requests/:id/accept`
- POST `/swap-requests/:id/reject`
- POST `/swap-requests/:id/cancel`

Health:

- GET `/healthz` -> { status: 'ok' }

## Business Rules (implemented / to refine)

- Capacity check before assignment
- Overlap check on assignments
- Availability check (override flag supported)
- Swap accept atomically reassigns shift

## Swagger Docs

After starting the server, visit: `http://localhost:3000/api-docs`
Run to regenerate specs file after adding integration tests:

```bash
bin/rails rswag:specs:swaggerize
```

## Testing

Run RSpec:

```bash
bin/rspec
```

## Environment Variables

See `.env.example` for required keys.

## Frontend Integration Notes

Include the JWT from login/register responses and send it on each request.
Handle 401 by redirecting to login. For assignment validation errors, surface `details` array.

## Next Steps / Improvements

- Add policy objects for finer authorization
- Add more request specs for shifts, employees, swap workflow
- Enhance Swagger coverage for all endpoints
- Add refresh token / token revocation list if needed
- Add indexing/optimizations on time queries

Things you may want to cover:

- Ruby version

- System dependencies

- Configuration

- Database creation

- Database initialization

- How to run the test suite

- Services (job queues, cache servers, search engines, etc.)

- Deployment instructions

- ...
