import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuBadge,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarRail,
} from "@/components/ui/sidebar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"
import {
  Activity,
  Bell,
  ClipboardList,
  FileBarChart,
  FileText,
  HeartPulse,
  Settings,
  Shield,
  Users,
} from "lucide-react"
import { NavLink, useLocation } from "react-router-dom"

type NavItem = {
  title: string
  icon: React.ComponentType<{ className?: string }>
  to: string
  badge?: string
}

const mainNav: NavItem[] = [
  {
    title: "Dashboard",
    icon: Activity,
    to: "/",
  },
  {
    title: "Patients",
    icon: Users,
    to: "/patients",
  },
  {
    title: "Caregivers",
    icon: HeartPulse,
    to: "/caregivers",
  },
  {
    title: "Notifications",
    icon: Bell,
    to: "/notifications",
    badge: "12",
  },
  {
    title: "Documents",
    icon: FileText,
    to: "/documents",
  },
  {
    title: "Subscriptions",
    icon: ClipboardList,
    to: "/subscriptions",
  },
  {
    title: "Reports",
    icon: FileBarChart,
    to: "/reports",
  },
  {
    title: "Settings",
    icon: Settings,
    to: "/settings",
  },
]

const adminTools: NavItem[] = [
  {
    title: "Audit Trail",
    icon: Shield,
    to: "/audit",
  },
]

export function AppSidebar() {
  const location = useLocation()

  const renderNav = (items: NavItem[]) =>
    items.map((item) => {
      const isActive =
        item.to === "/"
          ? location.pathname === "/"
          : location.pathname.startsWith(item.to)

      const Icon = item.icon

      return (
        <SidebarMenuItem key={item.title}>
          <SidebarMenuButton
            asChild
            isActive={isActive}
            tooltip={item.title}
            aria-label={item.title}
          >
            <NavLink
              to={item.to}
              className="flex items-center gap-2"
              end={item.to === "/"}
            >
              <Icon className="size-4" />
              <span className="transition-[margin,opacity] duration-200 ease-linear group-data-[collapsible=icon]/sidebar:-ml-6 group-data-[collapsible=icon]/sidebar:opacity-0">
                {item.title}
              </span>
            </NavLink>
          </SidebarMenuButton>
          {item.badge ? (
            <SidebarMenuBadge>
              <Badge variant="secondary" className="h-5 px-1 text-xs">
                {item.badge}
              </Badge>
            </SidebarMenuBadge>
          ) : null}
        </SidebarMenuItem>
      )
    })

  return (
    <Sidebar collapsible="icon" className="group/sidebar">
      <SidebarHeader className="px-3 py-4">
        <Button
          variant="ghost"
          size="sm"
          className={cn(
            "h-auto flex-col items-start justify-start px-2 py-1 text-left hover:bg-transparent",
            "transition-[padding,transform] duration-200 ease-linear",
            "group-data-[collapsible=icon]/sidebar:h-12 group-data-[collapsible=icon]/sidebar:flex-row group-data-[collapsible=icon]/sidebar:items-center group-data-[collapsible=icon]/sidebar:gap-2 group-data-[collapsible=icon]/sidebar:px-1 group-data-[collapsible=icon]/sidebar:py-0"
          )}
        >
          <span className="text-xs font-medium text-muted-foreground group-data-[collapsible=icon]/sidebar:hidden">
            Digital Nurse
          </span>
          <span
            className={cn(
              "text-lg font-semibold tracking-tight",
              "group-data-[collapsible=icon]/sidebar:text-base"
            )}
          >
            Care Portal
          </span>
        </Button>
      </SidebarHeader>
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>Main</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>{renderNav(mainNav)}</SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
        <SidebarGroup>
          <SidebarGroupLabel>Administrative</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>{renderNav(adminTools)}</SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>
      <SidebarFooter className="border-t border-sidebar-border px-4 py-3 text-xs text-muted-foreground">
        v0.1.0 · Mock environment
      </SidebarFooter>
      <SidebarRail />
    </Sidebar>
  )
}

