---
sidebar_position: 1
---

# Architecture

Immich uses a traditional client-server design, with a dedicated database for data persistence. The frontend clients communicate with backend services over HTTP using REST APIs.

## High Level Diagram

![Immich Architecture](./img/app-architecture.png)

The diagram shows clients communicating with the server via REST, as well as the flow of database between backend services.

## Clients

Immich has three main clients:

1. Mobile app - Android, iOS
2. Web app - Responsive website
3. CLI - Command-line utility for bulk upload

:::info
All three clients use [OpenAPI](./open-api.md) to auto-generate rest clients for easy integration. For more information about this process, see [OpenAPI](./open-api.md).
:::

### Mobile App

The mobile app is written in [Flutter](https://flutter.dev/). It uses [Isar Database](https://isar.dev/) for a local database and [Riverpod](https://riverpod.dev/) for state management.

### Web Client

The web app is a [TypeScript](https://www.typescriptlang.org/) project that uses [SvelteKit](https://kit.svelte.dev) and [Tailwindcss](https://tailwindcss.com/).

### CLI

The CLI is a [TypeScript](https://www.typescriptlang.org/) project that parses command line arguments to programmatically upload/import assets to an Immich server. See [Bulk Upload](/docs/features/bulk-upload.md) for more information about its usage.

## Server

The Immich backend is divided into several services, which are run as individual docker containers.

1. `immich-server` - Handle and respond to REST API requests
1. `immich-microservices` - Execute background jobs (thumbnail generation, metadata extraction, transcoding, etc.)
1. `immich-machine-learning` - Execute machine learning models
1. `postgres` - Persistent data storage
1. `redis`- Queue management for `immich-microservices`
1. `typesense`- Specialized database for search, specifically with vector comparison features

### Immich Server

The Immich Server is a [TypeScript](https://www.typescriptlang.org/) project written for [Node.js](https://nodejs.org/). It uses the [Nest.js](https://nestjs.com) framework, with [TypeORM](https://typeorm.io/) for database management. The server codebase also loosely follows the [Hexagonal Architecture](<https://en.wikipedia.org/wiki/Hexagonal_architecture_(software)>). Specifically, we aim to separate technology specific implementations (`infra/`) from core business logic (`domain/`).

#### REST Endpoints

The server is a list of HTTP endpoints and associated handlers (controllers). Each controller usually implements the following CRUD operations:

- `POST` `/<type>` - **Create**
- `GET` `/<type>` - **Read** (all)
- `GET` `/<type>/:id` - **Read** (by id)
- `PUT` `/<type>/:id` - **Updated** (by id)
- `DELETE` `/<type>/:id` - **Delete** (by id)

#### DTOs

The server uses [Domain Transfer Objects](https://en.wikipedia.org/wiki/Data_transfer_object) as public interfaces for the inputs (query, params, and body) and outputs (response) for each endpoint. DTOs translate to [OpenAPI](./open-api.md) schemas and control the generated code used by each client.

### Microservices

The Immich Microservices image uses the same `Dockerfile` as the Immich Server, but with a different entrypoint. The Immich Microservices service mainly handles executing jobs, which include the following:

- Thumbnail Generation
- Metadata Extraction
- Video Transcoding
- Object Tagging
- Facial Recognition
- Storage Template Migration
- Search (Typesense synchronization)
- Sidecar (see [XMP Sidecars](/docs/features/xmp-sidecars.md))
- Background jobs (file deletion, user deletion)

:::info
This list closely matches what is available on the [Administration > Jobs](/docs/administration/jobs.md) page, which provides some remote queue management capabilities.
:::

### Machine Learning

The machine learning service is written in [Python](https://www.python.org/) and uses [FastAPI](https://fastapi.tiangolo.com/) for HTTP communication.

All machine learning related operations have been externalized to this service, `immich-machine-learning`. Python is a natural choice for AI and machine learning. It also has some pretty specific hardware requirements. Running it as a separate container makes it possible to run the container on a separate machine, or easily disable it entirely.

Machine learning models are also quite _large_, requiring _quite a bit_ of memory. We are always looking for ways to improve and optimize this aspect of this container specifically.

### Postgres

Immich persists data in Postgres, which includes information about access and authorization, users, albums, asset, sharing settings, etc.

:::info
See [Database Migrations](./database-migrations.md) for more information about how to modify the database to create an index, modify a table, add a new column, etc.
:::

### Redis

Immich uses [Redis](https://redis.com/) via [BullMQ](https://docs.bullmq.io/) to manage job queues. Some jobs trigger subsequent jobs. For example, object detection relies on thumbnail generation and automatically run after one is generated.

### Typesense

Immich synchronizes some of the Postgres data into Typesense, so it can execute vector related queries in order to implement certain features including, facial recognition and CLIP search.

<!-- - [NGINX](https://www.nginx.com/) for internal communication between containers and load balancing when scaling. -->
