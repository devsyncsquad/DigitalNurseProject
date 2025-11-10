import {
  Area,
  AreaChart,
  CartesianGrid,
  Legend,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import type { VitalTrendPoint } from "@/mocks/data"

const lineColors = {
  systolic: "#2563eb",
  diastolic: "#7c3aed",
  heartRate: "#f97316",
}

export function VitalsTrendCard({ data }: { data: VitalTrendPoint[] }) {
  return (
    <Card className="col-span-1 lg:col-span-2">
      <CardHeader>
        <CardTitle className="text-sm font-semibold text-muted-foreground">
          10-Day Vital Trend
        </CardTitle>
      </CardHeader>
      <CardContent className="h-64">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={data}>
            <defs>
              <linearGradient
                id="systolic"
                x1="0"
                y1="0"
                x2="0"
                y2="1"
              >
                <stop offset="5%" stopColor={lineColors.systolic} stopOpacity={0.25} />
                <stop offset="95%" stopColor={lineColors.systolic} stopOpacity={0} />
              </linearGradient>
              <linearGradient
                id="diastolic"
                x1="0"
                y1="0"
                x2="0"
                y2="1"
              >
                <stop offset="5%" stopColor={lineColors.diastolic} stopOpacity={0.25} />
                <stop offset="95%" stopColor={lineColors.diastolic} stopOpacity={0} />
              </linearGradient>
              <linearGradient id="heartRate" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor={lineColors.heartRate} stopOpacity={0.25} />
                <stop offset="95%" stopColor={lineColors.heartRate} stopOpacity={0} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" vertical={false} opacity={0.3} />
            <XAxis dataKey="date" tickLine={false} axisLine={false} />
            <YAxis yAxisId="bp" tickLine={false} axisLine={false} width={40} />
            <YAxis
              yAxisId="hr"
              orientation="right"
              tickLine={false}
              axisLine={false}
              width={35}
            />
            <Tooltip
              cursor={{ strokeDasharray: "4 4" }}
              contentStyle={{
                borderRadius: "0.75rem",
                borderColor: "hsl(var(--border))",
                boxShadow: "var(--tw-shadow)",
              }}
            />
            <Legend />
            <Area
              yAxisId="bp"
              type="monotone"
              dataKey="systolic"
              stroke={lineColors.systolic}
              fill="url(#systolic)"
              strokeWidth={2}
              name="Systolic"
            />
            <Area
              yAxisId="bp"
              type="monotone"
              dataKey="diastolic"
              stroke={lineColors.diastolic}
              fill="url(#diastolic)"
              strokeWidth={2}
              name="Diastolic"
            />
            <Area
              yAxisId="hr"
              type="monotone"
              dataKey="heartRate"
              stroke={lineColors.heartRate}
              fill="url(#heartRate)"
              strokeWidth={2}
              name="Heart Rate"
            />
          </AreaChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  )
}

