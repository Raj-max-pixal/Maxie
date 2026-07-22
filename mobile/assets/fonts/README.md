# Fonts Directory

This directory contains custom fonts for MAXie Mobile.

## Included Fonts

### Poppins (Primary Font)
- `Poppins-Regular.ttf`
- `Poppins-Medium.ttf`
- `Poppins-SemiBold.ttf`
- `Poppins-Bold.ttf`

## Font Specifications

### Poppins
- **Designer**: Indian Type Foundry
- **License**: Open Font License (OFL)
- **Style**: Geometric sans-serif
- **Usage**: Headings, body text, UI elements

## Adding Custom Fonts

1. Place font files in this directory
2. Update `pubspec.yaml`:
```yaml
fonts:
  - family: YourFontName
    fonts:
      - asset: assets/fonts/YourFont-Regular.ttf
      - asset: assets/fonts/YourFont-Bold.ttf
        weight: 700
```

3. Use in Flutter:
```dart
Text(
  'Hello MAXie',
  style: TextStyle(fontFamily: 'YourFontName'),
)
```

## Current Status

⚠️ **No font files added yet**

Please add font files to this directory.

## Resources

- **Google Fonts**: https://fonts.google.com/
- **Free Fonts**: DaFont, FontSquirrel
- **Font Licensing**: Ensure proper licensing for commercial use
