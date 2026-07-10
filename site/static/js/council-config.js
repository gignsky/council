// Single source of truth for anything that may later talk to a server.
// Widgets must gate every network call on these values and fall back to
// local-only behaviour (localStorage) when apiBaseUrl is null.
export const config = {
  apiBaseUrl: null, // later: "https://api.frosted-mug.com"
  features: {
    unPersistence: false, // flip when the API exists
  },
};

export const isLocalOnly = () => config.apiBaseUrl === null;
