#Upcoming Release

#0.2.4

*Released: 01/23/2015*

**API Changes:**

- Due to the new requirement in ReSwift, that top level reducers need to be able to take an empty application state and return a hydrated one, `NavigationReducer` is no longer a top-level reducer. You now need to call it from within your app reducer. Refer to the docs for more details. - @Ben-G

**Other:**

- Drop iOS Deployment target to 8.0 - @Ben-G
- Add Support for watchOS, tvOS, OSX - @Ben-G
- Documentation updates - @Ben-G
