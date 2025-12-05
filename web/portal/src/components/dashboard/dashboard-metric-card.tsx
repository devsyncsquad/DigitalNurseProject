import { ArrowDown, ArrowRight, ArrowUp, Users, UserCog, Activity, Pill } from "lucide-react"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import type { DashboardMetric } from "@/mocks/data"
import { cn } from "@/lib/utils"

const trendIcon = {
  up: ArrowUp,
  down: ArrowDown,
  flat: ArrowRight,
} as const

const trendColor = {
  up: "text-emerald-500",
  down: "text-rose-500",
  flat: "text-muted-foreground",
} as const

const iconMap = {
  Users,
  UserCog,
  Activity,
  Pill,
} as const

const colorConfig = {
  blue: {
    bg: "bg-[#3B82F6]/10",
    iconBg: "bg-[#3B82F6]/20",
    iconColor: "text-[#3B82F6]",
    border: "border-[#3B82F6]/30",
    accent: "bg-[#3B82F6]",
  },
  purple: {
    bg: "bg-[#008080]/10",
    iconBg: "bg-[#008080]/20",
    iconColor: "text-[#008080]",
    border: "border-[#008080]/30",
    accent: "bg-[#008080]",
  },
  green: {
    bg: "bg-[#7FD991]/10",
    iconBg: "bg-[#7FD991]/20",
    iconColor: "text-[#7FD991]",
    border: "border-[#7FD991]/30",
    accent: "bg-[#7FD991]",
  },
  orange: {
    bg: "bg-[#66B2B2]/10",
    iconBg: "bg-[#66B2B2]/20",
    iconColor: "text-[#66B2B2]",
    border: "border-[#66B2B2]/30",
    accent: "bg-[#66B2B2]",
  },
} as const

export function DashboardMetricCard({
  metric,
}: {
  metric: DashboardMetric
}) {
  const Icon = trendIcon[metric.trend]
  const MetricIcon = metric.icon ? iconMap[metric.icon as keyof typeof iconMap] : null
  const colors = metric.color ? colorConfig[metric.color as keyof typeof colorConfig] : null

  return (
    <Card className={cn("relative overflow-hidden transition-all hover:shadow-md", colors?.bg && colors.bg)}>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-3">
        <CardTitle className="text-sm font-medium text-muted-foreground">
          {metric.title}
        </CardTitle>
        {MetricIcon && colors && (
          <div className={cn("rounded-lg p-2.5", colors.iconBg)}>
            <MetricIcon className={cn("size-5", colors.iconColor)} />
          </div>
        )}
      </CardHeader>
      <CardContent className="space-y-3 pt-0">
        <div className="space-y-2">
          <div className="flex items-baseline gap-2">
            <span className="text-4xl font-bold tracking-tight">
              {metric.value}
            </span>
          </div>
          {metric.description && (
            <p className="text-xs text-muted-foreground leading-relaxed">
              {metric.description}
            </p>
          )}
          {metric.label && (
            <p className="text-sm text-muted-foreground">{metric.label}</p>
          )}
        </div>
        {(metric.change || metric.changeLabel) && (
          <div className="flex items-center gap-2 text-xs text-muted-foreground">
            {metric.change && (
              <span
                className={cn(
                  "inline-flex items-center gap-1 rounded-full bg-muted px-2 py-0.5 font-medium",
                  metric.trend === "up" && "bg-emerald-500/10 text-emerald-600",
                  metric.trend === "down" && "bg-rose-500/10 text-rose-600"
                )}
              >
                <Icon className={cn("size-3", trendColor[metric.trend])} />
                {metric.change}
              </span>
            )}
            {metric.changeLabel && <span>{metric.changeLabel}</span>}
          </div>
        )}
        {colors && (
          <div className={cn("absolute bottom-0 left-0 right-0 h-1.5", colors.accent)} />
        )}
      </CardContent>
    </Card>
  )
}

