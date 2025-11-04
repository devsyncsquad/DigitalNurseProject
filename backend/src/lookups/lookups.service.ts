import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class LookupsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Get lookup values by domain
   */
  async findByDomain(domain: string) {
    const lookups = await this.prisma.lookup.findMany({
      where: {
        lookupDomain: domain,
        isActive: true,
      },
      orderBy: {
        sortOrder: 'asc',
      },
    });

    return lookups.map((lookup) => ({
      code: lookup.lookupCode,
      label: lookup.lookupLabel,
      sortOrder: lookup.sortOrder,
    }));
  }

  /**
   * Get all lookup domains
   */
  async getDomains() {
    const domains = await this.prisma.lookup.findMany({
      distinct: ['lookupDomain'],
      where: {
        isActive: true,
      },
      select: {
        lookupDomain: true,
      },
    });

    return domains.map((d) => d.lookupDomain);
  }
}

