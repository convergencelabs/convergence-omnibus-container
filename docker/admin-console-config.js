const path = window.location.pathname.replace(/[^/]*$/, '');

const AdminConsoleConfig = {
  SERVER_SOCKET_URL: path + "../api/realtime",
  SERVER_REST_URL: path + "../api/rest/v1",
  ENVIRONMENT: "production",
  BASE_HREF: path
};
