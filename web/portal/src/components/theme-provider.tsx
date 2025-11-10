import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react"

type Theme = "light" | "dark" | "system"

type ThemeProviderState = {
  theme: Theme
  resolvedTheme: "light" | "dark"
  setTheme: (theme: Theme) => void
}

const ThemeProviderContext = createContext<ThemeProviderState | undefined>(
  undefined
)

function getSystemTheme(): "light" | "dark" {
  if (typeof window === "undefined") return "light"
  return window.matchMedia("(prefers-color-scheme: dark)").matches
    ? "dark"
    : "light"
}

type ThemeProviderProps = {
  children: ReactNode
  defaultTheme?: Theme
  storageKey?: string
}

export function ThemeProvider({
  children,
  defaultTheme = "system",
  storageKey = "digital-nurse-theme",
}: ThemeProviderProps) {
  const [theme, setThemeState] = useState<Theme>(() => {
    if (typeof window === "undefined") return defaultTheme
    const stored = window.localStorage.getItem(storageKey) as Theme | null
    return stored ?? defaultTheme
  })

  const [resolvedTheme, setResolvedTheme] = useState<"light" | "dark">(() => {
    return theme === "system" ? getSystemTheme() : theme
  })

  const applyTheme = useCallback(
    (value: Theme) => {
      const root = window.document.documentElement
      const resolved = value === "system" ? getSystemTheme() : value

      root.classList.remove("light", "dark")
      root.classList.add(resolved)
      root.style.colorScheme = resolved

      setResolvedTheme(resolved)
    },
    [setResolvedTheme]
  )

  useEffect(() => {
    if (typeof window === "undefined") return

    applyTheme(theme)
    window.localStorage.setItem(storageKey, theme)
  }, [theme, storageKey, applyTheme])

  useEffect(() => {
    if (theme !== "system") return

    const listener = (event: MediaQueryListEvent) => {
      const resolved = event.matches ? "dark" : "light"
      const root = window.document.documentElement
      root.classList.remove("light", "dark")
      root.classList.add(resolved)
      root.style.colorScheme = resolved
      setResolvedTheme(resolved)
    }

    const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    mediaQuery.addEventListener("change", listener)
    return () => mediaQuery.removeEventListener("change", listener)
  }, [theme])

  const value = useMemo<ThemeProviderState>(
    () => ({
      theme,
      resolvedTheme,
      setTheme: setThemeState,
    }),
    [theme, resolvedTheme]
  )

  return (
    <ThemeProviderContext.Provider value={value}>
      {children}
    </ThemeProviderContext.Provider>
  )
}

// eslint-disable-next-line react-refresh/only-export-components
export function useTheme() {
  const context = useContext(ThemeProviderContext)
  if (!context) {
    throw new Error("useTheme must be used within a ThemeProvider")
  }

  return context
}

