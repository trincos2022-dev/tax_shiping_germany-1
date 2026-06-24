-- CreateTable
CREATE TABLE "Settings_de" (
    "id" TEXT NOT NULL,
    "shop" TEXT NOT NULL,
    "taxPercentage" DOUBLE PRECISION NOT NULL,
    "carrierCharge" DOUBLE PRECISION NOT NULL,
    "updatedAt" TIMESTAMP(6) NOT NULL,
    "usdToEuroRate" DOUBLE PRECISION NOT NULL,

    CONSTRAINT "settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProductMapping_de" (
    "id" TEXT NOT NULL,
    "shop" TEXT NOT NULL,
    "sku" TEXT NOT NULL,
    "ingramPartNumber" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "price" DECIMAL,

    CONSTRAINT "ProductMapping_de_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "shopify_products_final_Germany" (
    "id" BIGSERIAL NOT NULL,
    "title" TEXT,
    "body_html" TEXT,
    "handle" TEXT,
    "vendor" TEXT,
    "product_type" TEXT,
    "tags" TEXT,
    "images" JSONB,
    "sku" TEXT,
    "inventory_management" TEXT,
    "inventory_quantity" INTEGER,
    "price" DECIMAL,
    "compare_at_price" DECIMAL,
    "barcode" TEXT,
    "specs_table" TEXT,
    "information" TEXT,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "part_number" TEXT,
    "source_type" TEXT,

    CONSTRAINT "shopify_products_final_Germany_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProductSyncJob_de" (
    "id" TEXT NOT NULL,
    "shop" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "processed" INTEGER NOT NULL DEFAULT 0,
    "total" INTEGER NOT NULL DEFAULT 0,
    "error" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finishedAt" TIMESTAMP(3),
    "cursorSku" TEXT,

    CONSTRAINT "ProductSyncJob_de_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RequestLog_de" (
    "id" TEXT NOT NULL,
    "shop" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "endpoint" TEXT NOT NULL,
    "method" TEXT NOT NULL,
    "requestBody" TEXT,
    "responseBody" TEXT,
    "status" INTEGER,
    "error" TEXT,
    "durationMs" INTEGER,
    "createdAt" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "requestlog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Settings_shop_key" ON "Settings_de"("shop");

-- CreateIndex
CREATE INDEX "Settings_shop_idx" ON "Settings_de"("shop");

-- CreateIndex
CREATE INDEX "ProductMapping_de_shopDomain_idx" ON "ProductMapping_de"("shop");

-- CreateIndex
CREATE UNIQUE INDEX "ProductMapping_de_shopDomain_sku_idx" ON "ProductMapping_de"("shop", "sku");

-- CreateIndex
CREATE UNIQUE INDEX "shopify_products_final_Germany_sku_key" ON "shopify_products_final_Germany"("sku");

-- CreateIndex
CREATE INDEX "idx_products_id" ON "shopify_products_final_Germany"("id");

-- CreateIndex
CREATE INDEX "ProductSyncJob_de_status_idx" ON "ProductSyncJob_de"("status");

-- CreateIndex
CREATE INDEX "ProductSyncJob_de_createdAt_idx" ON "ProductSyncJob_de"("createdAt");

-- CreateIndex
CREATE INDEX "ProductSyncJob_de_shop_idx" ON "ProductSyncJob_de"("shop");

-- CreateIndex
CREATE INDEX "RequestLog_createdAt_idx" ON "RequestLog_de"("createdAt");

-- CreateIndex
CREATE INDEX "RequestLog_shop_idx" ON "RequestLog_de"("shop");
