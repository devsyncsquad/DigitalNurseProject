import { FileText, Link, ShieldCheck } from "lucide-react"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import type { DocumentRecord } from "@/mocks/data"

export function DocumentsSummaryCard({
  documents,
}: {
  documents: DocumentRecord[]
}) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-sm font-semibold text-muted-foreground">
          Recent Documents
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        {documents.map((doc) => (
          <div
            key={doc.id}
            className="flex items-start justify-between gap-3 rounded-lg border border-border/60 p-3 text-sm"
          >
            <div className="flex flex-1 items-start gap-3">
              <span className="rounded-full bg-muted p-2">
                <FileText className="size-4 text-primary" />
              </span>
              <div className="space-y-1">
                <div className="flex flex-wrap items-center gap-x-2 gap-y-1 text-sm font-medium">
                  {doc.type}
                  <Badge variant="outline" className="text-xs text-muted-foreground">
                    {doc.patient}
                  </Badge>
                </div>
                <p className="text-xs text-muted-foreground">
                  Authored by {doc.author} · {doc.createdAt}
                </p>
                <div className="flex items-center gap-2 text-xs text-muted-foreground">
                  <ShieldCheck className="size-3.5" />
                  <span>{doc.visibility} visibility</span>
                </div>
              </div>
            </div>
            <div className="flex flex-col items-end gap-2 text-xs text-muted-foreground">
              <Badge variant="secondary">{doc.status}</Badge>
              <button className="inline-flex items-center gap-1 text-primary">
                <Link className="size-3.5" />
                Preview
              </button>
            </div>
          </div>
        ))}
      </CardContent>
    </Card>
  )
}

