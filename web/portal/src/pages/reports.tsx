import { useMemo, useState } from "react"
import { reportSchedules } from "@/mocks/data"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Download, FileSpreadsheet, Timer } from "lucide-react"
import { format } from "date-fns"

export default function ReportsPage() {
  const [frequency, setFrequency] = useState<"All" | "Daily" | "Weekly" | "Monthly">(
    "All"
  )
  const [search, setSearch] = useState("")

  const filtered = useMemo(() => {
    return reportSchedules.filter((report) => {
      const matchesFrequency = frequency === "All" || report.frequency === frequency
      const matchesSearch =
        search.length === 0 ||
        report.title.toLowerCase().includes(search.toLowerCase()) ||
        report.scope.toLowerCase().includes(search.toLowerCase())
      return matchesFrequency && matchesSearch
    })
  }, [frequency, search])

  return (
    <section className="space-y-6">
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div>
          <h1 className="text-3xl font-semibold tracking-tight">
            Reports & Analytics
          </h1>
          <p className="text-sm text-muted-foreground">
            Generate adherence, vital trend, and caregiver activity summaries.
          </p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" className="gap-2">
            <FileSpreadsheet className="size-4" />
            Export history
          </Button>
          <Button className="gap-2">
            <Download className="size-4" />
            New report
          </Button>
        </div>
      </div>

      <Card>
        <CardHeader className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <CardTitle className="text-sm font-semibold text-muted-foreground">
            Scheduled exports
          </CardTitle>
          <div className="flex flex-wrap items-center gap-2">
            <Input
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Search reports or scopes"
              className="md:w-72"
            />
            <Select
              value={frequency}
              onValueChange={(value) => setFrequency(value as typeof frequency)}
            >
              <SelectTrigger className="w-36">
                <SelectValue placeholder="Frequency" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="All">All</SelectItem>
                <SelectItem value="Daily">Daily</SelectItem>
                <SelectItem value="Weekly">Weekly</SelectItem>
                <SelectItem value="Monthly">Monthly</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardHeader>
        <CardContent className="overflow-hidden">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Title</TableHead>
                <TableHead>Frequency</TableHead>
                <TableHead>Recipients</TableHead>
                <TableHead>Scope</TableHead>
                <TableHead>Next Run</TableHead>
                <TableHead />
              </TableRow>
            </TableHeader>
            <TableBody>
              {filtered.map((report) => (
                <TableRow key={report.id}>
                  <TableCell className="font-medium">
                    {report.title}
                  </TableCell>
                  <TableCell>
                    <Badge variant="secondary">{report.frequency}</Badge>
                  </TableCell>
                  <TableCell>
                    <div className="flex flex-wrap gap-1">
                      {report.recipients.map((recipient) => (
                        <Badge key={recipient} variant="outline" className="text-[10px]">
                          {recipient}
                        </Badge>
                      ))}
                    </div>
                  </TableCell>
                  <TableCell className="text-xs text-muted-foreground">
                    {report.scope}
                  </TableCell>
                  <TableCell className="text-xs text-muted-foreground">
                    {format(report.nextRun, "MMM dd, yyyy · HH:mm")}
                  </TableCell>
                  <TableCell>
                    <Button variant="ghost" size="sm">
                      Manage
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
          {filtered.length === 0 ? (
            <div className="rounded-lg border border-dashed border-border/60 py-10 text-center text-sm text-muted-foreground">
              No reports match the selected filters.
            </div>
          ) : null}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-sm font-semibold text-muted-foreground">
            Scheduling overview
          </CardTitle>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-3">
          {[
            {
              title: "Automated digests",
              value: `${reportSchedules.length}`,
              hint: "Active recurring exports",
            },
            {
              title: "Median delivery time",
              value: "08:00 PKT",
              hint: "Default delivery window",
            },
            {
              title: "Pending drafts",
              value: "3",
              hint: "Awaiting approver review",
            },
          ].map((item) => (
            <div
              key={item.title}
              className="rounded-xl border border-border/70 bg-muted/20 p-4"
            >
              <div className="flex items-center gap-2 text-xs text-muted-foreground">
                <Timer className="size-4" />
                {item.title}
              </div>
              <p className="mt-2 text-2xl font-semibold tracking-tight">
                {item.value}
              </p>
              <p className="text-xs text-muted-foreground">{item.hint}</p>
            </div>
          ))}
        </CardContent>
      </Card>
    </section>
  )
}

