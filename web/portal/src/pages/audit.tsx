import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Shield, Download, ListFilter } from "lucide-react"

const mockAuditEvents = [
  {
    id: "evt-1220",
    time: "2025-02-12 09:24",
    actor: "maria.aslam@digitalnurse.app",
    action: "Role updated",
    detail: "Promoted Hassan Raza to premium tier",
    sensitivity: "High",
  },
  {
    id: "evt-1219",
    time: "2025-02-12 08:11",
    actor: "sidra.khan@digitalnurse.app",
    action: "Caregiver invitation",
    detail: "Invited Bilal Hussain to Ayesha Khan",
    sensitivity: "Medium",
  },
  {
    id: "evt-1218",
    time: "2025-02-11 22:45",
    actor: "system@digitalnurse.app",
    action: "Login attempt",
    detail: "Failed MFA challenge for user hassan.raza",
    sensitivity: "Critical",
  },
]

const sensitivityTone = {
  Low: "bg-muted text-muted-foreground",
  Medium: "bg-amber-500/10 text-amber-600",
  High: "bg-rose-500/10 text-rose-600",
  Critical: "bg-rose-500/20 text-rose-700",
} as const

export default function AuditTrailPage() {
  return (
    <section className="space-y-6">
      <header className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div>
          <h1 className="text-3xl font-semibold tracking-tight">Audit Trail</h1>
          <p className="text-sm text-muted-foreground">
            Review authentication attempts, role changes, and high-risk actions.
          </p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" className="gap-2">
            <ListFilter className="size-4" />
            Filter
          </Button>
          <Button className="gap-2">
            <Download className="size-4" />
            Export
          </Button>
        </div>
      </header>

      <Card>
        <CardHeader className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <div>
            <CardTitle className="text-sm font-semibold text-muted-foreground">
              Event log
            </CardTitle>
            <p className="text-xs text-muted-foreground">
              Immutable audit record retained for 7 years.
            </p>
          </div>
          <Input placeholder="Search actor or action" className="md:w-72" />
        </CardHeader>
        <CardContent className="overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Timestamp</TableHead>
                <TableHead>Actor</TableHead>
                <TableHead>Action</TableHead>
                <TableHead>Details</TableHead>
                <TableHead>Sensitivity</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {mockAuditEvents.map((event) => (
                <TableRow key={event.id}>
                  <TableCell className="text-xs text-muted-foreground">
                    {event.time}
                  </TableCell>
                  <TableCell className="font-medium">{event.actor}</TableCell>
                  <TableCell>{event.action}</TableCell>
                  <TableCell className="text-xs text-muted-foreground">
                    {event.detail}
                  </TableCell>
                  <TableCell>
                    <Badge className={sensitivityTone[event.sensitivity as keyof typeof sensitivityTone]}>
                      {event.sensitivity}
                    </Badge>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <div className="rounded-xl border border-border/70 bg-muted/20 p-4 text-sm text-muted-foreground">
        <Shield className="mr-2 inline size-4 text-primary" />
        Audit service replicates to warm standby region with 15-minute RPO.
      </div>
    </section>
  )
}

