# Skill Icon Asset Paths

V7.8B prepares the project for PNG skill icons without requiring them yet.

Expected path pattern:

```text
assets/icons/skills/<class>/<skill_slug>.png
```

Examples:

```text
assets/icons/skills/warrior/cleave.png
assets/icons/skills/warrior/charge.png
assets/icons/skills/rogue/poison_arrow.png
assets/icons/skills/paladin/smite.png
assets/icons/skills/mage/fireball.png
```

Current behavior:

- The UI still uses text icon fallbacks such as `CL`, `CH`, `FB`, and `SM`.
- Action bar slots now have stronger icon-slot styling.
- The Skills tab lists the future PNG path for each skill.

Next step:

Add actual PNG files at these paths, then wire texture loading into the slot/icon controls.
