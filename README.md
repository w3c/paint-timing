# PerformancePageLoadTiming firstPaint

Web developers require more information on page load performance in the wild. There's no single point in time which represents when a page had loaded – there's a series of key moments during pageload which developers care about. 

We propose adding a new `PerformanceEntry` object, which will report the times of these key moments.
`firstPaint` is the first of these momements, and reports when the browser first paints anything non-white after a navigation.

```javascript
interface PerformancePageLoadTiming : PerformanceEntry {};
```

PerformancePageLoadTiming entries will have an `entryType` of "loadTime". Each entry will have a `firstPaint` attribute, which is a `DOMHighResTimeStamp`.

## Computation of `firstPaint`
The browser has performed a "paint" when it has TODO

More formally, we consider the browser to have "painted" a document when it has updated "the rendering or user interface of that Document and its browsing context to reflect the current state". See the HTML spec's section on the event loop processing model – [section 7.12](https://html.spec.whatwg.org/multipage/webappapis.html#event-loop-processing-model).

`firstPaint` reports the time since `navigationStart` until the first time the browser paints anything non-white.

## Using `firstPaint`
`firstPaint` is used by registering a `PerformanceObserver`.

```javascript
window.onload = () => { 
var observer = new PerformanceObserver((list) => {
  for (let perfEntry of list.getEntries()) {
     console.log("firstPaint :" + perfEntry.firstPaint);
  }
});

observer.observe({entryTypes: ["longtask"]});
}
```

## TODO
* More rigourously define what we mean by "paint".
