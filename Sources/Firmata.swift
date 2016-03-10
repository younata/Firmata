import CFirmata
#if os(Linux)
import Glibc
#endif

public protocol Firmata {
    func setServo(pin: Int, angle: Int)
    func setPWM(pin: Int, width: Int)

    func analogRead(pin: Int, callback: Double -> Void)
    func digitalRead(pin: Int, callback: Bool -> Void)
}

public enum FirmataError: ErrorType {
    case notAllocated
}

public final class Firmata23: Firmata {
    private let firmata: UnsafeMutablePointer<t_firmata>

    private var servos: [Int: UnsafeMutablePointer<t_servo>] = [:]

    public init() throws {
        self.firmata = firmata_new(UnsafeMutablePointer<Int8>())

        if self.firmata == nil {
            throw FirmataError.notAllocated
        }
    }

    deinit {
        if self.firmata != nil {
            free(self.firmata)
        }

        for value in self.servos.values {
            if value != nil {
                free(value)
            }
        }
    }

    public func setServo(pin: Int, angle: Int) {
        let servo: UnsafeMutablePointer<t_servo>
        if let value = self.servos[pin] {
            servo = value
        } else {
            servo = servo_attach(self.firmata, Int32(pin))
        }

        servo_write(servo, Int32(angle))
    }

    public func setPWM(pin: Int, width: Int) {
        firmata_analogWrite(self.firmata, Int32(pin), Int32(width))
    }

    public func analogRead(pin: Int, callback: Double -> Void) {
        self.readTransaction(pin) {
            callback(Double($0) / 1024.0)
        }
    }

    public func digitalRead(pin: Int, callback: Bool -> Void) {
        self.readTransaction(pin) {
            callback($0 == 1)
        }
    }

    private func readTransaction(pin: Int, callback: UInt32 -> Void) {
        firmata_pull(self.firmata)
        let pin = firmata_get_pin(self.firmata, Int32(pin))
        callback(pin.value)
    }
}
