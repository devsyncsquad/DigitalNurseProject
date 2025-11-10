import { AlertTriangle, Info, ShieldAlert } from "lucide-react"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import type { DashboardAlert } from "@/mocks/data"

const severityTone = {
  low: "bg-muted text-muted-foreground",
  medium: "bg-amber-500/10 text-amber-600",
  high: "bg-rose-500/10 text-rose-600",
} as const

const severityIcon = {
  low: Info,
  medium: AlertTriangle,
  high: ShieldAlert,
} as const

export function AlertsCard({ alerts }: { alerts: DashboardAlert[] }) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-sm font-semibold text-muted-foreground">
          Active Escalations
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {alerts.map((alert) => {
          const Icon = severityIcon[alert.severity]

          return (
            <div
              key={alert.id}
              className="rounded-lg border border-border/60 p-3"
            >
              <div className="flex items-start justify-between gap-3">
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <h3 className="font-medium">{alert.title}</h3>
                    <Badge className={severityTone[alert.severity]}>
                      <Icon className="mr-1 size-3.5" />
                      {alert.severity.toUpperCase()}
                    </Badge>
                  </div>
                  <p className="text-xs text-muted-foreground">
                    Patient: {alert.patient}
                  </p>
                </div>
                <span className="text-xs text-muted-foreground">
                  {alert.createdAt}
                </span>
              </div>
              <p className="mt-2 text-sm text-muted-foreground">
                {alert.description}
              </p>
            </div>
          )
        })}
      </CardContent>
    </Card>
  )
}

