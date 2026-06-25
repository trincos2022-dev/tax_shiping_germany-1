-- CreateTable
CREATE TABLE "ShippingCalculationLog_de" (
    "id" UUID NOT NULL,
    "shop" TEXT NOT NULL,
    "sku" TEXT NOT NULL,
    "basePrice" DOUBLE PRECISION NOT NULL,
    "taxAmount" DOUBLE PRECISION NOT NULL,
    "carrierCharge" DOUBLE PRECISION NOT NULL,
    "total" DOUBLE PRECISION NOT NULL,
    "status" TEXT NOT NULL,
    "error" TEXT,
    "createdAt" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ShippingCalculationLog_de_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ShippingCalculationLog_createdAt_idx" ON "ShippingCalculationLog_de"("createdAt");

-- CreateIndex
CREATE INDEX "ShippingCalculationLog_shop_idx" ON "ShippingCalculationLog_de"("shop");
