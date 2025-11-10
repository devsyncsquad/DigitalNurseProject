import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from "@/components/ui/tabs"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Switch } from "@/components/ui/switch"
import { Label } from "@/components/ui/label"
import { Badge } from "@/components/ui/badge"
import { ShieldAlert, Globe2 } from "lucide-react"

export default function SettingsPage() {
  return (
    <section className="space-y-6">
      <header className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div>
          <h1 className="text-3xl font-semibold tracking-tight">
            Platform Settings
          </h1>
          <p className="text-sm text-muted-foreground">
            Configure localization, notification templates, and security policies.
          </p>
        </div>
        <Button variant="outline">Audit changes</Button>
      </header>

      <Tabs defaultValue="localization" className="space-y-6">
        <TabsList className="flex w-full justify-start gap-2 bg-muted/40">
          <TabsTrigger value="localization">Localization</TabsTrigger>
          <TabsTrigger value="notifications">Notification templates</TabsTrigger>
          <TabsTrigger value="security">Security & compliance</TabsTrigger>
        </TabsList>

        <TabsContent value="localization" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle className="text-sm font-semibold text-muted-foreground">
                Language management
              </CardTitle>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="default-language">Default portal language</Label>
                <Input id="default-language" value="English (US)" readOnly />
              </div>
              <div className="space-y-2">
                <Label htmlFor="secondary-language">Secondary language</Label>
                <Input id="secondary-language" value="Urdu (Pakistan)" readOnly />
              </div>
              <div className="md:col-span-2 space-y-2">
                <Label>Preview content</Label>
                <Textarea
                  rows={4}
                  value="Digital Nurse empowers caregivers with real-time guidance and adherence insights."
                  readOnly
                />
                <div className="flex items-center gap-2 text-xs text-muted-foreground">
                  <Globe2 className="size-3.5" />
                  Localization updates sync nightly with mobile translations.
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="notifications" className="space-y-4">
          <Card>
            <CardHeader className="flex flex-col gap-1 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <CardTitle className="text-sm font-semibold text-muted-foreground">
                  Template governance
                </CardTitle>
                <p className="text-xs text-muted-foreground">
                  Update copy, channels, and version history for automated alerts.
                </p>
              </div>
              <Button size="sm">Create template</Button>
            </CardHeader>
            <CardContent className="grid gap-4 md:grid-cols-2">
              {[
                {
                  name: "Missed Dose Escalation",
                  channel: "Push",
                  status: "Active",
                },
                {
                  name: "Vitals Alert · High BP",
                  channel: "SMS",
                  status: "Draft",
                },
                {
                  name: "Subscription Renewal",
                  channel: "Email",
                  status: "Active",
                },
              ].map((template) => (
                <div
                  key={template.name}
                  className="rounded-xl border border-border/70 bg-muted/20 p-4 text-sm"
                >
                  <div className="flex items-center justify-between">
                    <span className="font-medium">{template.name}</span>
                    <Badge variant="secondary">{template.status}</Badge>
                  </div>
                  <p className="mt-1 text-xs text-muted-foreground">
                    Channel: {template.channel}
                  </p>
                  <Button variant="ghost" size="sm" className="mt-3">
                    Edit template
                  </Button>
                </div>
              ))}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="security" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle className="text-sm font-semibold text-muted-foreground">
                Security controls
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex items-center justify-between rounded-xl border border-border/70 bg-muted/20 p-4">
                <div>
                  <p className="font-medium">Enforce multi-factor authentication</p>
                  <p className="text-xs text-muted-foreground">
                    Required for all web users, matches mobile policy.
                  </p>
                </div>
                <Switch defaultChecked />
              </div>
              <div className="flex items-center justify-between rounded-xl border border-border/70 bg-muted/20 p-4">
                <div>
                  <p className="font-medium">Session timeout</p>
                  <p className="text-xs text-muted-foreground">
                    Automatic logout after 30 minutes of inactivity.
                  </p>
                </div>
                <Badge variant="outline">30 minutes</Badge>
              </div>
              <div className="rounded-xl border border-border/70 bg-muted/20 p-4 text-sm text-muted-foreground">
                <ShieldAlert className="mb-2 size-4 text-primary" />
                HIPAA alignment: audit trail retention 7 years, PHI export
                encryption, caregiver consent logging.
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </section>
  )
}

