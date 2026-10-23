# Performance, motion and production polish

- Profile, not debug, builds for frame timings. Use Flutter DevTools: https://docs.flutter.dev/tools/devtools and performance guide: https://docs.flutter.dev/perf/ui-performance
- Establish baseline before targets: cold start, 90th/95th percentile route transition, scroll frames, memory peak, app size, image decode and API latency.
- Audit widget rebuild scope, large lists, image cache, SVG/animation size, expensive effects, repeated JSON/model work, synchronous disk operations.
- Animation must not delay confirmation or hide financial state; provide reduced-motion behavior when appropriate.
- Use skeletons only when they clarify structure; always provide error/empty states and retry rules.
- Do not add a state management or animation library solely for novelty. Record measured benefit and bundle impact.
