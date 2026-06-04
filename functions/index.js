const admin = require("firebase-admin");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");

admin.initializeApp();

exports.sendUserNotification = onDocumentCreated(
  "users/{userId}/notifications/{notificationId}",
  async (event) => {
    const notification = event.data && event.data.data();
    if (!notification) return;

    const userId = event.params.userId;
    const userSnapshot = await admin.firestore().collection("users").doc(userId).get();
    const tokens = userSnapshot.get("fcmTokens") || [];
    if (!tokens.length) return;

    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: notification.title || "Nisarga",
        body: notification.body || "",
      },
      data: {
        type: notification.type || "general",
        route: notification.route || "/",
      },
    });
  },
);

exports.sendBroadcastNotification = onDocumentCreated(
  "broadcasts/{broadcastId}",
  async (event) => {
    const broadcast = event.data && event.data.data();
    if (!broadcast) return;

    const users = await admin.firestore().collection("users").get();
    const writes = [];
    users.forEach((user) => {
      writes.push(
        user.ref.collection("notifications").add({
          userId: user.id,
          title: broadcast.title || "Nisarga",
          body: broadcast.body || "",
          type: "broadcast",
          route: broadcast.route || "/notifications",
          read: false,
          createdAt: new Date().toISOString(),
        }),
      );
    });

    await Promise.all(writes);
  },
);
