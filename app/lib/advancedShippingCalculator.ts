import prisma from "../db.server";

interface ShippingItem {
  weight?: number | null;
  source_type?: string | null;
  product_type?: string | null;
}

const MAX_PARCEL_WEIGHT = 31.5;


function parseSourceType(sourceType?: string | null): string {
  const raw = (sourceType ?? "unknown").toString().trim();

  let parsedSource = raw;

  if (raw.includes("(")) {
    const match = raw.match(/\(([^)]+)\)/);
    parsedSource = match?.[1] ?? raw;
  }

  parsedSource = parsedSource.toLowerCase();

  console.log("Source Type Raw:", raw);
  console.log("Parsed Source:", parsedSource);

  return parsedSource || "unknown";
}

export class AdvancedShippingEngineDE {

  async calculate(
    items: ShippingItem[],
    postcode?: string,
  ): Promise<number> {
    const shipments = this.groupBySource(items);

    let totalShipping = 0;
    let totalWeight = 0;

  for (const shipment of shipments) {
    let shipmentPrice = 0;
    let shipmentWeight = 0;

    const normalItems: ShippingItem[] = [];

    for (const item of shipment) {
      const itemWeight =
        item.weight != null &&
        Number(item.weight) > 0
          ? Number(item.weight)
          : this.getDefaultWeight(item);

      shipmentWeight += itemWeight;

      if (this.isHeavySingleItem(item)) {
        const heavyPrice =
          await this.getRate(itemWeight);

        console.log("🚚 [HEAVY ITEM]", {
          itemWeight,
          heavyPrice,
        });

        shipmentPrice += heavyPrice;
      } else {
        normalItems.push(item);
      }
    }

    if (normalItems.length > 0) {
      shipmentPrice += await this.calculatePackedShipment(
        normalItems,
      );
    }

    totalWeight += shipmentWeight;

    console.log("📦 [SHIPMENT]", {
      supplier: parseSourceType(
        shipment?.[0]?.source_type,
      ),
      weight: shipmentWeight,
      price: shipmentPrice,
    });

    totalShipping += shipmentPrice;
  }

    const finalShipping = Math.ceil(totalShipping);

    console.log("✅ [FINAL RESULT]", {
      postcode,
      totalWeight,
      finalShipping,
    });

    return finalShipping;
  }

  groupBySource(items: ShippingItem[]): ShippingItem[][] {
    const groups: Record<string, ShippingItem[]> = {};

    items.forEach((item) => {
      const key = parseSourceType(item.source_type);

      if (!groups[key]) {
        groups[key] = [];
      }

      groups[key].push(item);
    });

    return Object.values(groups);
  }

  getDefaultWeight(item: ShippingItem): number {
    switch (item.product_type) {
      case "Servers":
        return 30;

      default:
        return 2;
    }
  }

  isHeavySingleItem(item: ShippingItem): boolean {
  const weight =
    item.weight != null
      ? Number(item.weight)
      : this.getDefaultWeight(item);

  return weight > MAX_PARCEL_WEIGHT;
}

async calculatePackedShipment(
  items: ShippingItem[],
): Promise<number> {
  const parcels: number[] = [];

  const sortedItems = [...items].sort(
  (a, b) => {
    const weightA =
      a.weight != null
        ? Number(a.weight)
        : this.getDefaultWeight(a);

    const weightB =
      b.weight != null
        ? Number(b.weight)
        : this.getDefaultWeight(b);

    return weightB - weightA;
  },
);

  for (const item of sortedItems) {
    const weight =
      item.weight != null &&
      Number(item.weight) > 0
        ? Number(item.weight)
        : this.getDefaultWeight(item);

    let packed = false;

    for (let i = 0; i < parcels.length; i++) {
      if (
        parcels[i] + weight <=
        MAX_PARCEL_WEIGHT
      ) {
        parcels[i] += weight;
        packed = true;
        break;
      }
    }

    if (!packed) {
      parcels.push(weight);
    }
  }

  let totalPrice = 0;

  for (const parcelWeight of parcels) {
    const parcelPrice =
      await this.getRate(parcelWeight);

    console.log("📦 [PACKED PARCEL]", {
      parcelWeight,
      parcelPrice,
    });

    totalPrice += parcelPrice;
  }

  return totalPrice;
}

  async getRate(weight: number): Promise<number> {
    const weightNum = Number(weight);

    console.log("📍 [GERMANY RATE LOOKUP]", weightNum);

    try {
      const rules = await prisma.shipping_rules_DE.findMany({
        orderBy: [{ Min_Weight: "asc" }],
      });

      const match = rules.find((rule) => {
        const min = Number(rule.Min_Weight ?? 0);
        const max = Number(rule.Max_Weight ?? 0);


      return (
        weightNum >= min &&
        weightNum < max
      );
      });

      if (match) {
        const Price = Number(match.Price ?? 0);

        console.log("✅ [MATCH]", {
          weight: weightNum,
          Price,
        });

        return Price;
      }

      const lastRule = rules[rules.length - 1];

      const fallbackPrice = Number(lastRule?.Price ?? 0);

      console.log("⚠️ [FALLBACK]", {
        weight: weightNum,
        fallbackPrice,
      });

      return fallbackPrice;
    } catch (error) {
      console.log("❌ [RATE ERROR]", error);

      return 0;
    }
  }
}