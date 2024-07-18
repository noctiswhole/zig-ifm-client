const std = @import("std");
const network = @import("network");
const IFM = @import("IFM.zig");

const IFMParameters = enum {
    browDown_L,
    browDown_R,
    browInnerUp,
    browOuterUp_L,
    browOuterUp_R,
    cheekPuff,
    cheekSquint_L,
    cheekSquint_R,
    eyeBlink_L,
    eyeBlink_R,
    eyeLookDown_L,
    eyeLookDown_R,
    eyeLookIn_L,
    eyeLookIn_R,
    eyeLookOut_L,
    eyeLookOut_R,
    eyeLookUp_L,
    eyeLookUp_R,
    eyeSquint_L,
    eyeSquint_R,
    eyeWide_L,
    eyeWide_R,
    jawForward,
    jawLeft,
    jawOpen,
    jawRight,
    mouthClose,
    mouthDimple_L,
    mouthDimple_R,
    mouthFrown_L,
    mouthFrown_R,
    mouthFunnel,
    mouthLeft,
    mouthLowerDown_L,
    mouthLowerDown_R,
    mouthPress_L,
    mouthPress_R,
    mouthPucker,
    mouthRight,
    mouthRollLower,
    mouthRollUpper,
    mouthShrugLower,
    mouthShrugUpper,
    mouthSmile_L,
    mouthSmile_R,
    mouthStretch_L,
    mouthStretch_R,
    mouthUpperUp_L,
    mouthUpperUp_R,
    noseSneer_L,
    noseSneer_R,
    tongueOut,
    trackingStatus,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 3) {
        @panic("Invalid arguments.");
    }

    // Setup network
    try network.init();
    defer network.deinit();

    var socket = try network.Socket.create(.ipv4, .udp);
    defer socket.close();

    const localhost = try network.Address.IPv4.parse("0.0.0.0");
    const address = try network.Address.IPv4.parse(args[1]);
    const port = try std.fmt.parseInt(u16, args[2], 10);

    try socket.bind(.{
        .address = .{
            .ipv4 = localhost,
        },
        .port = port,
    });

    const buflen = 1024;
    var buffer: [buflen]u8 = undefined;

    // Initialize IFM
    const endpoint = network.EndPoint{
        .address = .{
            .ipv4 = address,
        },
        .port = port,
    };
    _ = try socket.sendTo(endpoint, "iFacialMocap_sahuasouryya9218sauhuiayeta91555dy3719");

    var ifm = IFM{};

    while (true) {
        const recv_msg = try socket.receiveFrom(buffer[0..buflen]);

        var iter = std.mem.splitScalar(u8, buffer[0..recv_msg.numberOfBytes], '|');
        while (iter.next()) |item| {
            const index = std.mem.indexOfScalar(u8, item, '-') orelse {
                continue;
            };

            // not supporting rotational values yet
            const param = item[0..index];
            const value = std.fmt.parseInt(u8, item[index+1..item.len], 10) catch {
                continue;
            };
            const ifm_param = std.meta.stringToEnum(IFMParameters, param) orelse {
                continue;
            };

            switch (ifm_param) {
                .browDown_L => ifm.browDownL = value,
                .browDown_R => ifm.browDownR = value,
                .browInnerUp => ifm.browInnerUp = value,
                .browOuterUp_L => ifm.browOuterUpL = value,
                .browOuterUp_R => ifm.browOuterUpR = value,
                .cheekPuff => ifm.cheekPuff = value,
                .cheekSquint_L => ifm.cheekSquintL = value,
                .cheekSquint_R => ifm.cheekSquintR = value,
                .eyeBlink_L => ifm.eyeBlinkL = value,
                .eyeBlink_R => ifm.eyeBlinkR = value,
                .eyeLookDown_L => ifm.eyeLookDownL = value,
                .eyeLookDown_R => ifm.eyeLookDownR = value,
                .eyeLookIn_L => ifm.eyeLookInL = value,
                .eyeLookIn_R => ifm.eyeLookInR = value,
                .eyeLookOut_L => ifm.eyeLookOutL = value,
                .eyeLookOut_R => ifm.eyeLookOutR = value,
                .eyeLookUp_L => ifm.eyeLookUpL = value,
                .eyeLookUp_R => ifm.eyeLookUpR = value,
                .eyeSquint_L => ifm.eyeSquintL = value,
                .eyeSquint_R => ifm.eyeSquintR = value,
                .eyeWide_L => ifm.eyeWideL = value,
                .eyeWide_R => ifm.eyeWideR = value,
                .jawForward => ifm.jawForward = value,
                .jawLeft => ifm.jawLeft = value,
                .jawOpen => ifm.jawOpen = value,
                .jawRight => ifm.jawRight = value,
                .mouthClose => ifm.mouthClose = value,
                .mouthDimple_L => ifm.mouthDimpleL = value,
                .mouthDimple_R => ifm.mouthDimpleR = value,
                .mouthFrown_L => ifm.mouthFrownL = value,
                .mouthFrown_R => ifm.mouthFrownR = value,
                .mouthFunnel => ifm.mouthFunnel = value,
                .mouthLeft => ifm.mouthLeft = value,
                .mouthLowerDown_L => ifm.mouthLowerDownL = value,
                .mouthLowerDown_R => ifm.mouthLowerDownR = value,
                .mouthPress_L => ifm.mouthPressL = value,
                .mouthPress_R => ifm.mouthPressR = value,
                .mouthPucker => ifm.mouthPucker = value,
                .mouthRight => ifm.mouthRight = value,
                .mouthRollLower => ifm.mouthRollLower = value,
                .mouthRollUpper => ifm.mouthRollUpper = value,
                .mouthShrugLower => ifm.mouthShrugLower = value,
                .mouthShrugUpper => ifm.mouthShrugUpper = value,
                .mouthSmile_L => ifm.mouthSmileL = value,
                .mouthSmile_R => ifm.mouthSmileR = value,
                .mouthStretch_L => ifm.mouthStretchL = value,
                .mouthStretch_R => ifm.mouthStretchR = value,
                .mouthUpperUp_L => ifm.mouthUpperUpL = value,
                .mouthUpperUp_R => ifm.mouthUpperUpR = value,
                .noseSneer_L => ifm.noseSneerL = value,
                .noseSneer_R => ifm.noseSneerR = value,
                .tongueOut => ifm.tongueOut = value,
                .trackingStatus => ifm.trackingStatus = value,
            }
        }
        
        // print out struct
        std.debug.print("\x1B[2J\x1B[H", .{});
        inline for (std.meta.fields(IFM)) | field | {
            std.debug.print("{s} - {d}\n", .{field.name, @field(ifm, field.name)});
        }
    }
}
