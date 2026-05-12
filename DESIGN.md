---
name: Edenred Design System
colors:
  surface: '#fcf8fa'
  surface-dim: '#dcd9db'
  surface-bright: '#fcf8fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f5'
  surface-container: '#f0edef'
  surface-container-high: '#eae7e9'
  surface-container-highest: '#e4e2e4'
  on-surface: '#1b1b1d'
  on-surface-variant: '#45464d'
  inverse-surface: '#303032'
  inverse-on-surface: '#f3f0f2'
  outline: '#76777d'
  outline-variant: '#c6c6cd'
  surface-tint: '#565e74'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#131b2e'
  on-primary-container: '#7c839b'
  inverse-primary: '#bec6e0'
  secondary: '#bb0300'
  on-secondary: '#ffffff'
  secondary-container: '#e7170b'
  on-secondary-container: '#fffbff'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#001b3c'
  on-tertiary-container: '#0083f5'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#ffdad4'
  secondary-fixed-dim: '#ffb4a8'
  on-secondary-fixed: '#410100'
  on-secondary-fixed-variant: '#930200'
  tertiary-fixed: '#d5e3ff'
  tertiary-fixed-dim: '#a7c8ff'
  on-tertiary-fixed: '#001b3c'
  on-tertiary-fixed-variant: '#004788'
  background: '#fcf8fa'
  on-background: '#1b1b1d'
  surface-variant: '#e4e2e4'
  navy-dark: '#0F172A'
  navy-medium: '#1E293B'
  red-alert: '#F72717'
  red-dark: '#CF2E2E'
  cyan-brand: '#0E8AFF'
  purple-accent: '#711CFF'
  light-slate: '#F8FAFC'
  gray-light: '#F6F6F6'
  border-gray: '#CBD5E1'
  gray-medium: '#B3B3B3'
  gray-dark: '#747474'
  slate-muted: '#334155'
  slate-light: '#94A3B8'
  brand-light-bg: '#F1F7FF'
  warning: '#FCB900'
  warning-alt: '#E8CA2F'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.2'
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-md:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: 0.02em
  button-text:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: '1'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  section: 80px
---

# Design System Inspired by Edenred
## 1. Visual Theme & Atmosphere
Edenred's design system embodies a modern, professional corporate identity grounded in trust and clarity. The system combines deep navy foundations with striking red accents, creating a bold yet sophisticated atmosphere suited to employee benefits and HR solutions. The visual language emphasizes efficiency and approachability through clean layouts, generous whitespace, and carefully orchestrated color interactions. Rounded elements and soft shadows convey accessibility, while the strong dark-to-light contrast ensures excellent readability and visual hierarchy. The design balances corporate formality with human-centered warmth, making complex benefit solutions feel intuitive and welcoming.
**Key Characteristics**
- Deep navy (`#0F172A`) as the dominant structural color, commanding 51% of the design palette
- Bold red (`#F72717`) accent for high-impact CTAs and error states
- Clean, minimalist aesthetic with strategic use of whitespace
- Rounded button treatments (`100px` radius) creating friendly, approachable interactions
- Soft drop shadows (5px blur, `rgba(0, 0, 0, 0.1)`) for subtle depth without heaviness
- Strong typographic hierarchy with Ubuntu family and bold weights for headings
- Semi-transparent overlays and layered compositions on hero imagery
## 2. Color Palette & Roles
### Primary
- **Navy Dark** (`#0F172A`): Primary structural color for text, navigation, backgrounds, and primary UI elements. Dominant throughout the interface.
- **Navy Medium** (`#1E293B`): Secondary structural color for supporting text, secondary containers, and hierarchy differentiation.
### Accent Colors
- **Red Alert** (`#F72717`): Primary brand accent and call-to-action buttons. High-visibility red for "Pedir Demo" CTAs and interactive highlights.
- **Red Dark** (`#CF2E2E`): Darker red variant for error states and alternative accent contexts.
### Interactive
- **Cyan Brand** (`#0E8AFF`): Tertiary accent for links and secondary interactive elements.
- **Purple Accent** (`#711CFF`): Tertiary interactive color for advanced UI states.
### Neutral Scale
- **White** (`#FFFFFF`): Primary surface, card backgrounds, text on dark backgrounds.
- **Black** (`#000000`): Maximum contrast text, strong emphasis.
- **Light Slate** (`#F8FAFC`): Subtle background for light sections and inactive states.
- **Gray Light** (`#F6F6F6`): Neutral background alternative.
- **Border Gray** (`#CBD5E1`): Input borders, dividers, and subtle separators.
- **Gray Medium** (`#B3B3B3`): Secondary text, disabled states.
- **Gray Dark** (`#747474`): Tertiary text, helper text, smaller supporting labels.
### Surface & Borders
- **Slate Muted** (`#334155`): Alternative neutral for borders and subtle backgrounds.
- **Slate Light** (`#94A3B8`): Lightest neutral for minimal borders and accents.
- **Brand Light Background** (`#F1F7FF`): Pale blue background for information contexts.
### Semantic / Status
- **Error** (`#F72717`): Error validation, destructive actions, alerts.
- **Warning** (`#FCB900`): Warning alerts and caution indicators.
- **Warning Alternative** (`#E8CA2F`): Secondary warning color for extended warning contexts.
## 3. Typography Rules
### Font Family
**Primary:** Ubuntu (sans-serif) — Primary font family for all UI elements, body text, and secondary headings.
Fallback: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif`
**Secondary:** Edenred (custom sans-serif) — Display and heading font for h1 and button labels requiring maximum impact.
Fallback: Ubuntu, `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif`
## 4. Component Stylings
### Buttons
**Primary Button (Red)**
- Background: `#F72717`
- Text Color: `#FFFFFF`
- Font: Edenred, 18px, weight 600
- Padding: 12px 24px
- Border Radius: 100px
### Cards & Containers
**Card (Standard)**
- Background: `#FFFFFF`
- Text Color: `#0F172A`
- Border Radius: 10px
- Box Shadow: `rgba(0, 0, 0, 0.1) 5px 5px 40px 0px`
## 5. Layout Principles
**Base Unit:** 4px
**Border Radius Scale**
- **100px** (`border-radius: 100px`) — Pill-shaped buttons, fully rounded elements
