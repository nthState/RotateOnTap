import SwiftUI


extension View {
  func rotateOnTap(angle: Angle = Angle.degrees(15)) -> some View {
    modifier(RotateOnTap(angle: angle))
  }
}

struct RotateOnTap: ViewModifier {

  let startAngle: Angle

  @State var angle: Angle = .zero
  @State var isPressed: Bool = false
  @State var xAxis: CGFloat = 0
  @State var yAxis: CGFloat = 0
  @State var zAxis: CGFloat = 0
  @State var rotationPoint: UnitPoint = .center
  @State private var stateLocation: CGPoint = .zero
  @State var buttonSize: CGSize = .zero

  public init(angle: Angle) {
    self.startAngle = angle
  }

  func map(minRange: CGFloat, maxRange: CGFloat, minDomain: CGFloat, maxDomain: CGFloat, value: CGFloat) -> CGFloat {
    return minDomain + (maxDomain - minDomain) * (value - minRange) / (maxRange - minRange)
  }

  var simpleDrag: some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { value in
        self.stateLocation = value.location
        isPressed = true

        let width = buttonSize.width
        let height = buttonSize.height
        let halfWidth = buttonSize.width/2
        let halfHeight = buttonSize.height/2

        let rx = map(minRange: 0, maxRange: width, minDomain: -halfWidth, maxDomain: halfWidth, value: value.location.x)
        let ry = map(minRange: 0, maxRange: height, minDomain: -halfHeight, maxDomain: halfHeight, value: value.location.y)

        var px = map(minRange: -halfWidth, maxRange: halfWidth, minDomain: 0, maxDomain: 1, value: rx * -1)
        var py = map(minRange: -halfHeight, maxRange: halfHeight, minDomain: 0, maxDomain: 1, value: ry * -1)

        if abs(rx) > abs(ry) {
          yAxis = 1
          if rx < 0 {
            yAxis = -1
          }
          py = 0.5
        } else {
          xAxis = -1
          if ry < 0 {
            xAxis = 1
          }
          px = 0.5
        }


        let m = max(px, py)


        angle = startAngle * m
        rotationPoint = UnitPoint(x: px, y: py)

        //        let angleRad = CGPoint(x: 60, y: 40).angleToPoint(pointOnCircle: value.location)
        //        let dist = CGPoint(x: 60, y: 40).distanceToPoint(otherPoint: value.location)
        //        let Xdist = rx
        //        let Ydist = ry



        //
        //
        ////        let i = -sin(ry)
        ////        let j = cos(ry)*sin(rx)
        ////        let k = cos(ry)*cos(rx)
        //
        //        //angle = Angle.degrees(map(minRange: 0, maxRange: 120, minDomain: -60, maxDomain: 60, value: value.location.x))
        //        angle = Angle.radians(angleRad)
        //        //angle = Angle.degrees(15)
        //        xAxis = -i //map(minRange: -60, maxRange: 60, minDomain: 0, maxDomain: 1, value: Xdist)
        //        yAxis = -j //map(minRange: -40, maxRange: 40, minDomain: 0, maxDomain: 1, value: Ydist)
        //        //zAxis = k
        //        print("rp", rotationPoint, rx, ry, "axis", i, j, k)
        //yAxis = 0
      }
      .onEnded { value in
        isPressed = false
        angle = .zero
        rotationPoint = .center
        xAxis = 0
        yAxis = 0
        zAxis = 0
      }
  }

  private var sizeView: some View {
      GeometryReader { geometry in
          Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
      }
  }

  func body(content: Content) -> some View {
    content
      .coordinateSpace(name: "Test")
      .background(sizeView)
      .rotation3DEffect(angle, axis: (x: xAxis, y: yAxis, z: zAxis), anchor: rotationPoint)
      .gesture(
        simpleDrag
      )
      .onPreferenceChange(SizePreferenceKey.self) { value in
        buttonSize = value
      }
  }

}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension CGPoint {
  func angleToPoint(pointOnCircle: CGPoint) -> CGFloat {

    let originX = pointOnCircle.x - self.x
    let originY = pointOnCircle.y - self.y
    var radians = atan2(originY, originX)

    while radians < 0 {
      radians += CGFloat(2 * Double.pi)
    }

    return radians
  }
  func distanceToPoint(otherPoint: CGPoint) -> CGFloat {
    return sqrt(pow((otherPoint.x - x), 2) + pow((otherPoint.y - y), 2))
  }
}
