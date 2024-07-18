const std = @import("std");
const network = @import("network");
const IFM = @import("IFM.zig");

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

            const value = try std.fmt.parseInt(u8, item[index+1..item.len], 10);
            if (std.mem.eql(u8, item[0..index], "mouthClose")) {
                ifm.mouthClose = value;
            }
        }
        
        std.debug.print("\x1B[2J\x1B[HmouthClose - {d}\n", .{ifm.mouthClose});
    }
}
