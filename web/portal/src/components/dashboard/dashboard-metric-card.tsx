import { ArrowDown, ArrowRight, ArrowUp } from "lucide-react"

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

export function DashboardMetricCard({
  metric,
}: {
  metric: DashboardMetric
}) {
  const Icon = trendIcon[metric.trend]

  return (
    <Card>
      <CardHeader className="space-y-1">
        <CardTitle className="text-sm font-medium text-muted-foreground">
          {metric.title}
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        <div className="space-y-1">
          <p className="text-sm text-muted-foreground">{metric.label}</p>
          <span className="text-3xl font-semibold tracking-tight">
            {metric.value}
          </span>
        </div>
        <div className="flex items-center gap-2 text-xs text-muted-foreground">
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
          <span>{metric.changeLabel}</span>
        </div>
      </CardContent>
    </Card>
  )
}

