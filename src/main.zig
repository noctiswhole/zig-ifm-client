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
                .browDown_L => ifm.brow_down_l = value,
                .browDown_R => ifm.brow_down_r = value,
                .browInnerUp => ifm.brow_inner_up = value,
                .browOuterUp_L => ifm.brow_outer_up_l = value,
                .browOuterUp_R => ifm.brow_outer_up_r = value,
                .cheekPuff => ifm.cheek_puff = value,
                .cheekSquint_L => ifm.cheek_squint_l = value,
                .cheekSquint_R => ifm.cheek_squint_r = value,
                .eyeBlink_L => ifm.eye_blink_l = value,
                .eyeBlink_R => ifm.eye_blink_r = value,
                .eyeLookDown_L => ifm.eye_look_down_l = value,
                .eyeLookDown_R => ifm.eye_look_down_r = value,
                .eyeLookIn_L => ifm.eye_look_in_l = value,
                .eyeLookIn_R => ifm.eye_look_in_r = value,
                .eyeLookOut_L => ifm.eye_look_out_l = value,
                .eyeLookOut_R => ifm.eye_look_out_r = value,
                .eyeLookUp_L => ifm.eye_look_up_l = value,
                .eyeLookUp_R => ifm.eye_look_up_r = value,
                .eyeSquint_L => ifm.eye_squint_l = value,
                .eyeSquint_R => ifm.eye_squint_r = value,
                .eyeWide_L => ifm.eye_wide_l = value,
                .eyeWide_R => ifm.eye_wide_r = value,
                .jawForward => ifm.jaw_forward = value,
                .jawLeft => ifm.jaw_left = value,
                .jawOpen => ifm.jaw_open = value,
                .jawRight => ifm.jaw_right = value,
                .mouthClose => ifm.mouth_close = value,
                .mouthDimple_L => ifm.mouth_dimple_l = value,
                .mouthDimple_R => ifm.mouth_dimple_r = value,
                .mouthFrown_L => ifm.mouth_frown_l = value,
                .mouthFrown_R => ifm.mouth_frown_r = value,
                .mouthFunnel => ifm.mouth_funnel = value,
                .mouthLeft => ifm.mouth_left = value,
                .mouthLowerDown_L => ifm.mouth_lower_down_l = value,
                .mouthLowerDown_R => ifm.mouth_lower_down_r = value,
                .mouthPress_L => ifm.mouth_press_l = value,
                .mouthPress_R => ifm.mouth_press_r = value,
                .mouthPucker => ifm.mouth_pucker = value,
                .mouthRight => ifm.mouth_right = value,
                .mouthRollLower => ifm.mouth_roll_lower = value,
                .mouthRollUpper => ifm.mouth_roll_upper = value,
                .mouthShrugLower => ifm.mouth_shrug_lower = value,
                .mouthShrugUpper => ifm.mouth_shrug_upper = value,
                .mouthSmile_L => ifm.mouth_smile_l = value,
                .mouthSmile_R => ifm.mouth_smile_r = value,
                .mouthStretch_L => ifm.mouth_stretch_l = value,
                .mouthStretch_R => ifm.mouth_stretch_r = value,
                .mouthUpperUp_L => ifm.mouth_upper_up_l = value,
                .mouthUpperUp_R => ifm.mouth_upper_up_r = value,
                .noseSneer_L => ifm.nose_sneer_l = value,
                .noseSneer_R => ifm.nose_sneer_r = value,
                .tongueOut => ifm.tongue_out = value,
                .trackingStatus => ifm.tracking_status = value,
            }
        }
        
        // print out struct
        std.debug.print("\x1B[2J\x1B[H", .{});
        inline for (std.meta.fields(IFM)) | field | {
            std.debug.print("{s} - {d}\n", .{field.name, @field(ifm, field.name)});
        }
    }
}
