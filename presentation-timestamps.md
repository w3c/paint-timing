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

It would have the following shape:

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

## Security & privacy self review 

See [Self-Review Questionnaire: Security and Privacy](https://w3ctag.github.io/security-questionnaire/)

### 01. What information might this feature expose to Web sites or other parties, and for what purposes is that exposure necessary?

It exposes timing information of a platform/OS operation, a coarse approximation of "VSync". This is already exposed to some extend by the `requestAnimationFrame` callback timestamp.
It is necessary in order to reflect to web developers the impact on user experience performance in practice, as other metrics offer approximations that lose too much information.

#### 02. Do features in your specification expose the minimum amount of information necessary to enable their intended uses?

Yes.

#### 03. How do the features in your specification deal with personal information, personally-identifiable information (PII), or information derived from them?

This feature does not deal with personal information.

#### 04. How do the features in your specification deal with sensitive information?

This feature does not deal with sensitive information.

#### 05. Do the features in your specification introduce new state for an origin that persists across browsing sessions?

No. This feature only applies to the current document.

#### 06. Do the features in your specification expose information about the underlying platform to origins?

To some extent, the timing of committing a frame is information about the underlying platform, like the refresh rate.
However, this information is already exposed in other ways (the `requestAnimationFrame` callback timestamp),
and in this specification it is coarsened on top of the usual coarsening, to avoid exposing meaningful information in terms of security/fingerprinting.

#### 07. Does this specification allow an origin to send data to the underlying platform?

No.

#### 08. Do features in this specification allow an origin access to sensors on a user’s device?

No.

#### 09. What data do the features in this specification expose to an origin? Please also document what data is identical to data exposed by other features, in the same or different contexts.

Timing information only.

#### 10. Do feautres in this specification enable new script execution/loading mechanisms?

No.

#### 11. Do features in this specification allow an origin to access other devices?

No.

#### 12. Do features in this specification allow an origin some measure of control over a user agent's native UI?

None.

#### 13. What temporary identifiers do the features in this specification create or expose to the web?

None.

#### 14. How does this specification distinguish between behavior in first-party and third-party contexts?

Timing information receives extra coarsening in documents that are not cross-origin isolated.
Cross-origin isolation is more appropriate here than per-resource protections, as the same presentation timing is shared
across all the resources presented in the same frame, be it cross-origin or same-origin resources.

#### 15. How do the features in this specification work in the context of a browser’s Private Browsing or Incognito mode?

The feature is unaffected by these modes.

#### 16. Does this specification have both "Security Considerations" and "Privacy Considerations" sections?

Yes.

#### 17. Do features in your specification enable origins to downgrade default security protections?

Yes, using cross-origin isolation.

#### 18. What should this questionnaire have asked?

The questionnaire asked for sufficient information.
