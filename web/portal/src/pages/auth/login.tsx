import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Switch } from "@/components/ui/switch"
import { ThemeToggle } from "@/components/theme-toggle"
import { ShieldCheck, SmartphoneNfc } from "lucide-react"
import { Link } from "react-router-dom"

export default function LoginPage() {
  return (
    <div className="flex min-h-screen flex-col bg-gradient-to-br from-background via-background to-muted">
      <header className="flex items-center justify-between px-6 py-4">
        <div className="flex items-center gap-3">
          <ShieldCheck className="size-6 text-primary" />
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.2em] text-muted-foreground">
              Digital Nurse
            </p>
            <p className="text-base font-semibold tracking-tight">
              Care Portal Access
            </p>
          </div>
        </div>
        <ThemeToggle />
      </header>
      <div className="mx-auto flex w-full max-w-5xl flex-1 flex-col gap-6 px-6 pb-12 pt-4 md:flex-row">
        <div className="flex flex-1 flex-col justify-center gap-6 rounded-2xl border border-border/60 bg-card/60 p-8 shadow-sm backdrop-blur">
          <div>
            <h1 className="text-3xl font-semibold leading-tight">
              Welcome back, Care Team
            </h1>
            <p className="mt-2 text-sm text-muted-foreground">
              Log in with your organizational email. Multi-factor authentication
              follows after successful credential verification.
            </p>
          </div>
          <form className="space-y-6">
            <div className="space-y-2">
              <Label htmlFor="email">Work Email</Label>
              <Input
                id="email"
                type="email"
                placeholder="you@digitalnurse.app"
                autoComplete="email"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                placeholder="••••••••"
                autoComplete="current-password"
              />
            </div>
            <div className="flex items-center justify-between text-sm">
              <label className="flex items-center gap-2 text-muted-foreground">
                <Switch id="remember" />
                <span>Remember this device</span>
              </label>
              <Link
                to="/reset-password"
                className="font-medium text-primary hover:underline"
              >
                Forgot password?
              </Link>
            </div>
            <Button type="submit" className="w-full">
              Continue to Portal
            </Button>
          </form>
          <p className="text-xs text-muted-foreground">
            Having trouble?{" "}
            <Link to="/support" className="underline underline-offset-4">
              Contact support
            </Link>
          </p>
        </div>
        <div className="flex flex-1 flex-col justify-center gap-6 rounded-2xl border border-border/60 bg-muted/30 p-8 shadow-sm">
          <div className="flex items-center gap-3 text-primary">
            <SmartphoneNfc className="size-5" />
            <span className="text-sm font-semibold uppercase tracking-[0.25em]">
              Secure Access
            </span>
          </div>
          <div className="space-y-4 text-sm text-muted-foreground">
            <p>
              The Digital Nurse portal mirrors the mobile experience with added
              desktop workflows tailored for administrators, providers, and care
              coordinators.
            </p>
            <p>
              MFA is enforced for all roles. After initial login you will be
              prompted for either an email OTP or authenticator app code.
            </p>
            <p>
              Access is governed by role-based permissions aligned with HIPAA/
              GDPR controls. Every critical action is logged in the audit trail.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

