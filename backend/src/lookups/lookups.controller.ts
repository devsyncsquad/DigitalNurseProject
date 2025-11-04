import { Controller, Get, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { LookupsService } from './lookups.service';

@ApiTags('Lookups')
@Controller('lookups')
export class LookupsController {
  constructor(private readonly lookupsService: LookupsService) {}

  @Get('domains')
  @ApiOperation({ summary: 'Get all lookup domains' })
  @ApiResponse({ status: 200, description: 'List of domains' })
  getDomains() {
    return this.lookupsService.getDomains();
  }

  @Get(':domain')
  @ApiOperation({ summary: 'Get lookup values by domain' })
  @ApiResponse({ status: 200, description: 'List of lookup values' })
  findByDomain(@Param('domain') domain: string) {
    return this.lookupsService.findByDomain(domain);
  }
}

