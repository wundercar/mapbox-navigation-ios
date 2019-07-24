import Foundation
import CoreLocation
import MapboxDirections



/**
 RouterDelegate is a mid-level delegate that defines the messaging architechture between the NavigationService and its router. Developers generally shouldn't have to concern themselves with this class unless a custom core-navigation engine (conforming to NavigationService) is being written.
 
 You can use this protocol to:
 * Recieve navigation progress updates
 * Decide when to reroute the user
 * Decide what location updates are considered 'qualified'
 * Customize visual / spoken instructions that are presented to the user
 * Decide if battery monitoring should be disabled
 * Decide if the SDK should pause navigation when the user reaches an intermediate destination (for example, to show a interstitial modal UI)
 * Be informed when the SDK fails to fetch a new route
 * Be informed when the SDK is beginning or ending route-simulation
 * Be informed when the user is about to arrive, or has arrived at their destination
 - seealso: NavigationServiceDelegate
 */
@objc(MBRouterDelegate)
public protocol RouterDelegate: class {
    
    /**
     Returns whether the router should be allowed to calculate a new route.
     
     If implemented, this method is called as soon as the router detects that the user is off the predetermined route. Implement this method to conditionally prevent rerouting. If this method returns `true`, `router(_:willRerouteFrom:)` will be called immediately afterwards.
     
     - parameter router: The router that has detected the need to calculate a new route.
     - parameter location: The user’s current location.
     - returns: True to allow the router to calculate a new route; false to keep tracking the current route.
     */
    @objc(router:shouldRerouteFromLocation:)
    optional func router(_ router: Router, shouldRerouteFrom location: CLLocation) -> Bool

    /**
     Called immediately before the router calculates a new route.
     
     This method is called after `router(_:shouldRerouteFrom:)` is called, and before `router(_:didRerouteAlong:)` is called.
     
     - parameter router: The router that will calculate a new route.
     - parameter location: The user’s current location.
     */
    @objc(router:willRerouteFromLocation:)
    optional func router(_ router: Router, willRerouteFrom location: CLLocation)
    
    /**
     Called when a location has been identified as unqualified to navigate on.
     
     See `CLLocation.isQualified` for more information about what qualifies a location.
     
     - parameter router: The router that discarded the location.
     - parameter location: The location that will be discarded.
     - return: If `true`, the location is discarded and the `Router` will not consider it. If `false`, the location will not be thrown out.
     */
    @objc(router:shouldDiscardLocation:)
    optional func router(_ router: Router, shouldDiscard location: CLLocation) -> Bool

    /**
     Called immediately after the router receives a new route.
     
     This method is called after `router(_:willRerouteFrom:)` method is called.
     
     - parameter router: The router that has calculated a new route.
     - parameter route: The new route.
     */
    @objc(router:didRerouteAlongRoute:at:proactive:)
    optional func router(_ router: Router, didRerouteAlong route: Route, at location: CLLocation?, proactive: Bool)

    /**
     Called when the router fails to receive a new route.
     
     This method is called after `router(_:willRerouteFrom:)`.
     
     - parameter router: The router that has calculated a new route.
     - parameter error: An error raised during the process of obtaining a new route.
     */
    @objc(router:didFailToRerouteWithError:)
    optional func router(_ router: Router, didFailToRerouteWith error: Error)
    
    /**
     Called when the router updates the route progress model.
     
     - parameter router: The router that received the new locations.
     - parameter progress: the RouteProgress model that was updated.
     - parameter location: the guaranteed location, possibly snapped, associated with the progress update.
     - parameter rawLocation: the raw location, from the location manager, associated with the progress update.
     */
    @objc(router:didUpdateProgress:withLocation:rawLocation:)
    optional func router(_ router: Router, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation)
    
    /**
     Called when the router detects that the user has passed a point at which an instruction should be displayed.
     - parameter router: The router that passed the instruction point.
     - parameter instruction: The instruction to be presented.
     - parameter routeProgress: The route progress object that the router is updating.
     */
    @objc(router:didPassVisualInstructionPoint:routeProgress:)
    optional func router(_ router: Router, didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress)
    
    /**
     Called when the router detects that the user has passed a point at which an instruction should be spoken.
     - parameter router: The router that passed the instruction point.
     - parameter instruction: The instruction to be spoken.
     - parameter routeProgress: The route progress object that the router is updating.
     */
    @objc(router:didPassSpokenInstructionPoint:routeProgress:)
    optional func router(_ router: Router, didPassSpokenInstructionPoint instruction: SpokenInstruction, routeProgress: RouteProgress)
    
    /**
     Called as the router approaches a waypoint.
     
     This message is sent, once per progress update, as the user is approaching a waypoint. You can use this to cue UI, to do network pre-loading, etc.
     - parameter router: The router that is detecting the destination approach.
     - parameter waypoint: The waypoint that the service is arriving at.
     - parameter remainingTimeInterval: The estimated number of seconds until arrival.
     - parameter distance: The current distance from the waypoint, in meters.
     - important: This method will likely be called several times as you approach a destination. If only one consumption of this method is desired, then usage of an internal flag is recommended.
     */
    @objc(router:willArriveAtWaypoint:in:distance:)
    optional func router(_ router: Router, willArriveAt waypoint: Waypoint, after remainingTimeInterval:TimeInterval, distance: CLLocationDistance)
    
    /**
     Called when the router arrives at a waypoint.
     
     You can implement this method to prevent the router from automatically advancing to the next leg. For example, you can and show an interstitial sheet upon arrival and pause navigation by returning `false`, then continue the route when the user dismisses the sheet. If this method is unimplemented, the router automatically advances to the next leg when arriving at a waypoint.
     
     - postcondition: If you return false, you must manually advance to the next leg: obtain the value of the `routeProgress` property, then increment the `RouteProgress.legIndex` property.
     - parameter router: The router that has arrived at a waypoint.
     - parameter waypoint: The waypoint that the controller has arrived at.
     - returns: True to advance to the next leg, if any, or false to remain on the completed leg.
     */
    @objc(router:didArriveAtWaypoint:)
    optional func router(_ router: Router, didArriveAt waypoint: Waypoint) -> Bool
    
    /**
     Called when the router arrives at a waypoint.
     
     You can implement this method to allow the router to continue check and reroute the user if needed. By default, the user will not be rerouted when arriving at a waypoint.
     
     - parameter router: The router that has arrived at a waypoint.
     - parameter waypoint: The waypoint that the controller has arrived at.
     - returns: True to prevent the router from checking if the user should be rerouted.
     */
    @objc(router:shouldPreventReroutesWhenArrivingAtWaypoint:)
    optional func router(_ router: Router, shouldPreventReroutesWhenArrivingAt waypoint: Waypoint) -> Bool

    /**
     Called when the router will disable battery monitoring.
     
     Implementing this method will allow developers to change whether battery monitoring is disabled when the `Router` is deinited.
     
     - parameter router: The router that will change the state of battery monitoring.
     - returns: A bool indicating whether to disable battery monitoring when the RouteController is deinited.
     */
    @objc(routerShouldDisableBatteryMonitoring:)
    optional func routerShouldDisableBatteryMonitoring(_ router: Router) -> Bool
}

