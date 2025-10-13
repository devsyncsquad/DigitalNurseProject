import { prisma } from '../../config/database';
import { CreateLookupInput, UpdateLookupInput } from './lookups.schemas';

export class LookupService {
  async getAllLookups(domain?: string, isActive?: boolean) {
    const where: any = {};

    if (domain) {
      where.lookupDomain = domain;
    }

    if (isActive !== undefined) {
      where.isActive = isActive;
    }

    return await prisma.lookup.findMany({
      where,
      orderBy: [{ lookupDomain: 'asc' }, { sortOrder: 'asc' }, { lookupLabel: 'asc' }],
    });
  }

  async getLookupById(lookupId: string) {
    return await prisma.lookup.findUnique({
      where: { lookupId: BigInt(lookupId) },
    });
  }

  async getLookupByDomainAndCode(domain: string, code: string) {
    return await prisma.lookup.findFirst({
      where: {
        lookupDomain: domain,
        lookupCode: code,
      },
    });
  }

  async getLookupsByDomain(domain: string) {
    return await prisma.lookup.findMany({
      where: {
        lookupDomain: domain,
        isActive: true,
      },
      orderBy: [{ sortOrder: 'asc' }, { lookupLabel: 'asc' }],
    });
  }

  async createLookup(data: CreateLookupInput) {
    // Check if lookup already exists
    const existing = await this.getLookupByDomainAndCode(data.lookupDomain, data.lookupCode);

    if (existing) {
      throw new Error('Lookup with this domain and code already exists');
    }

    return await prisma.lookup.create({
      data: {
        lookupDomain: data.lookupDomain,
        lookupCode: data.lookupCode,
        lookupLabel: data.lookupLabel,
        sortOrder: data.sortOrder,
        isActive: data.isActive,
      },
    });
  }

  async updateLookup(lookupId: string, data: UpdateLookupInput) {
    return await prisma.lookup.update({
      where: { lookupId: BigInt(lookupId) },
      data: {
        lookupLabel: data.lookupLabel,
        sortOrder: data.sortOrder,
        isActive: data.isActive,
      },
    });
  }

  async deleteLookup(lookupId: string) {
    return await prisma.lookup.delete({
      where: { lookupId: BigInt(lookupId) },
    });
  }

  async getAllDomains() {
    const domains = await prisma.lookup.findMany({
      distinct: ['lookupDomain'],
      select: {
        lookupDomain: true,
      },
      orderBy: {
        lookupDomain: 'asc',
      },
    });

    return domains.map((d) => d.lookupDomain);
  }
}

export const lookupService = new LookupService();
