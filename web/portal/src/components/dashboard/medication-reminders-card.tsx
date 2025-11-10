import {
  BadgeCheck,
  Clock4,
  Pill,
  TriangleAlert,
  UserRound,
} from "lucide-react"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import type { MedicationReminder } from "@/mocks/data"
import { cn } from "@/lib/utils"

const statusConfig: Record<
  MedicationReminder["status"],
  { icon: React.ComponentType<{ className?: string }>; label: string; tone: string }
> = {
  upcoming: {
    icon: Clock4,
    label: "Upcoming",
    tone: "bg-amber-500/10 text-amber-600",
  },
  overdue: {
    icon: TriangleAlert,
    label: "Overdue",
    tone: "bg-rose-500/10 text-rose-600",
  },
  taken: {
    icon: BadgeCheck,
    label: "Logged",
    tone: "bg-emerald-500/10 text-emerald-600",
  },
}

export function MedicationRemindersCard({
  reminders,
}: {
  reminders: MedicationReminder[]
}) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-sm font-semibold text-muted-foreground">
          Medication Reminders
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        {reminders.map((reminder) => {
          const status = statusConfig[reminder.status]
          const Icon = status.icon

          return (
            <div
              key={reminder.id}
              className="flex items-start justify-between gap-3 rounded-lg border border-border/60 p-3"
            >
              <div className="flex flex-1 items-start gap-3">
                <Badge variant="secondary" className="rounded-full p-2.5">
                  <Pill className="size-4 text-primary" />
                </Badge>
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <h3 className="font-medium">{reminder.medication}</h3>
                    <Badge
                      variant="outline"
                      className="border-border/70 text-xs text-muted-foreground"
                    >
                      {reminder.schedule}
                    </Badge>
                  </div>
                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    <UserRound className="size-3.5" />
                    <span>{reminder.patient}</span>
                  </div>
                </div>
              </div>
              <div className="flex flex-col items-end gap-2">
                <Badge className={cn("gap-1", status.tone)}>
                  <Icon className="size-3.5" />
                  {status.label}
                </Badge>
                <span className="text-xs text-muted-foreground">
                  {reminder.dueAt}
                </span>
              </div>
            </div>
          )
        })}
      </CardContent>
    </Card>
  )
}

