const STORAGE_KEY = "commies.login";

class LoginStorage {
  static persist = (login) => {
    try {
      const serialized = JSON.stringify(login);
      localStorage.setItem(STORAGE_KEY, serialized);
    } catch (error) {
      console.error(error);
    }
  };

  static load = () => {
    try {
      const serialized = localStorage.getItem(STORAGE_KEY);

      if (serialized === null) {
        return {};
      } else {
        return JSON.parse(serialized);
      }
    } catch (_error) {
      return {};
    }
  };
}

export default LoginStorage;
