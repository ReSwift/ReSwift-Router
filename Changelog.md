# Upcoming

**Breaking API Changes:**
- Rename Components of the `Routable` protocol (#107) - @hlineholm


# 0.7.0

*Released: 2019-08-01*

**Breaking API Changes:**
- Remove use of `StandardAction` and `StandardActionConvertible` (#82) - @hlineholm

    - Removes the compatibility of this with `ReSwift-Recorder`, which itself is being deprecated.
    - Ensures compatibility with latest versions of `ReSwift` which have removed these types.
- Renamed argument labels for modern Swift conformance ([#116](<https://github.com/ReSwift/ReSwift-Router/pull/116>)) - @TaeJoongYoon
    - Renamed `routingActionsForTransitionFrom(_ oldRoute:,newRoute:)` method  to `routingActionsForTransition(from oldRoute:,to newRoute:)`
    - Renamed `routableIndexForRouteSegment(_ segment:)` method  to `routableIndex(for segment:)`

**Other:**
- Update to Swift 5  -- @djtech42
- Update to ReSwift 5.0.0 and fix project setup for SwiftPM & Carthage (#115, #124) - @djtech42, @DivineDominion

# 0.6.0

*Released: 6/29/2017*

**Other**:

- Update to ReSwift 4.0 - @Ben-G
- Lower iOS Deployment Target to 8.0 - @Ben-G

# 0.5.1

*Released: 11/24/2016*

**Other:**

- Fix iOS Deployment Target (Back to 9.1 from 10.1)  -  @Ben-G



# 0.5.0

*Released: 11/24/2016*

**Other:**

- Swift 3.0.1 / Xcode 8.1 updates -  @DivineDominion, @frranck

# 0.4.0

*Released: 09/21/2016*

**Other:**

- Swift 3 Migration - @Ben-G
- Documentation Fix - @excitedhoney

# 0.3.1

*Released: 07/16/2016*

**Fixes:**

- Expose `RouteHash` initializer publicly - @Ben-G

# 0.3.0

*Released: 06/28/2016*

**Other**:

- Update syntax to Swift 2.3 - @mjarvis
- Update to ReSwift 2.0.0 - @Ben-G

# 0.2.7

*Released: 03/23/2016*

**Fixes:**

- Fix issue when checking out with Carthage (#20) - @Ben-G

# 0.2.6

*Released: 03/20/2016*

**API Changes:**

- Provide route action that allows chosing between animated and un-animated route changes - @Ben-G
- Provide API for setting associated data for a certain route. This enables passing state information to subroutes - @Ben-G

**Other:**:

- Update ReSwift Dependency to 1.0 - @Ben-G
- Use a symbolic breakpoint in place of an `assertionFailure` for handling a stuck router - @Ben-G
- Documentation Fix - @jschmid

# 0.2.5

*Released: 02/22/2016*

**API Changes:**
- ReSwift-Router now uses the new substate selection API when subscribing to a store. As a result, the `HasNavigationState` protocol has been removed. This change also allows an app to have multiple routers. - @Ben-G

# 0.2.4

*Released: 01/23/2016*

**API Changes:**

- Due to the new requirement in ReSwift, that top level reducers need to be able to take an empty application state and return a hydrated one, `NavigationReducer` is no longer a top-level reducer. You now need to call it from within your app reducer. Refer to the docs for more details. - @Ben-G

**Other:**

- Drop iOS Deployment target to 8.0 - @Ben-G
- Add Support for watchOS, tvOS, OSX - @Ben-G
- Documentation updates - @Ben-G
