# `PaintTimingMixin`: Presentation timestamps and their meanings

Aligning different paint-related timestamps in all the relevant specs.

## Overview
When originally introduced, paint timing ("`first-paint`" and "`first-contentful-paint`") aspired to represent an important moment in terms of user experience - "The pixels on the screen" representing a certain state.
However, this is tricky in terms of interopability - that moment is not always measured in the same way, and is not part of the flow of operations covered by web standards.
In the paint-timing spec, a different time is used instead as the `startTime` - [the end of the "update the rendering" phase](https://html.spec.whatwg.org/multipage/webappapis.html#event-loop-processing-model%3Amark-paint-timing),
where the document is done setting up the rendering and hands over rendering to the user agent.
This is confusing and non-interoperable, as Chromium still reports the VSync-time, which sufficiently corresponds to "pixels on the screen".
In addition, the "long animation frame" timing exposes the hand-over time as its end time, and element-timing/largest contentful paint exposes the VSync time as its `renderTime`.

The `PaintTimingMixin` attempts to clean up this confusion, by always providing two timestamps, one mandatory and interoperative, one optional and somewhat implementation-defined.

## `PaintTimingMixin`

`PaintTimingMixin` is a mixin that would be included in the interfaces representing all the relevant performance entries:

- `event`
- `element`
- `largest-contentful-paint`
- `first-paint`
- `first-contentful-paint`
- `long-animation-frame`

It would the following shape:

```webidl
interface mixin PaintTimingMixin {
  // The time when the document finishes updating the rendering, handing over rendering to the user-agent
  readonly    attribute DOMHighResTimeStamp paintTime;

  // A coarsened implementation-specific time, approximately the "VSync" time when the new information was presented to the user.
  readonly    attribute DOMHighResTimeStamp? presentationTime;
};
```

* Note that `presentationTime` is optional: user-agents can opt to not expose them.

## Impact on current attributes
Currently paint timing's `startTime` and element timing's `renderTime` use the presentation time if that's available (Chromium), and the paint time if it's not (WebKit/Gecko).
In this proposal, this would be explicit: both paint timing's `startTime` and element timing's `renderTime` would return something like `presentationTime || paintTime`.
This would keep compatibility with what's out there today, allowing progressive enhancement and returning the "best known value" from these attributes.

## Conclusion

When exposing paint timings, we look for the right trade-off between "UX-precise" and "interoperable".
By exposing those as two timestamps, and making one of them optional, we give web developers the information that can help them optimize, without compromising on interoperability.
