# @imajin/ui

A modern React component library built with **Tailwind CSS**, **Radix UI**, and **Shadcn/ui** patterns.

## ✨ Features

- 🎨 **Tailwind CSS** - Utility-first CSS framework
- 🧩 **Radix UI** - Unstyled, accessible components
- 🎭 **Shadcn/ui** - Beautiful component patterns
- 📚 **Storybook** - Component documentation and testing
- 🔷 **TypeScript** - Full type safety
- 🎯 **Tree-shakable** - Import only what you need
- 🌙 **Dark mode** - Built-in dark mode support

## 📦 Installation

```bash
pnpm add @imajin/ui
```

## 🚀 Usage

### Import Styles

Add the CSS import to your app's global stylesheet:

```css
@import "@imajin/ui/globals.css";
```

### Tailwind Configuration

Extend your Tailwind config to include the UI package:

```js
// tailwind.config.js
module.exports = {
  content: [
    // ... your content paths
    "../../packages/ui/src/**/*.{js,ts,jsx,tsx}",
  ],
  presets: [require("@imajin/ui/tailwind.config.js")],
};
```

### Components

```tsx
import { Button, Card, CardHeader, CardTitle, CardContent } from "@imajin/ui";

export default function Example() {
  return (
    <Card className="w-[350px]">
      <CardHeader>
        <CardTitle>Hello World</CardTitle>
      </CardHeader>
      <CardContent>
        <p>This is a beautiful card component.</p>
        <Button className="mt-4">Click me</Button>
      </CardContent>
    </Card>
  );
}
```

## 🧩 Available Components

- **Button** - Various button styles and sizes
- **Card** - Flexible card layouts
- **Input** - Form input fields
- **Label** - Form labels with accessibility
- **Code** - Inline code styling

## 📖 Storybook

Run Storybook for component documentation:

```bash
pnpm storybook
```

## 🛠️ Development

```bash
# Install dependencies
pnpm install

# Start Storybook
pnpm storybook

# Build the package
pnpm build

# Type checking
pnpm check-types

# Linting
pnpm lint
```

## 🎨 Customization

The design system uses CSS variables for theming. Override these in your app:

```css
:root {
  --primary: 210 40% 20%;
  --primary-foreground: 210 40% 98%;
  /* ... other variables */
}
```

## 📱 Responsive Design

All components are built with responsive design in mind using Tailwind's responsive utilities.

## ♿ Accessibility

Components are built on Radix UI primitives, ensuring excellent accessibility out of the box.

## 📄 License

MIT 