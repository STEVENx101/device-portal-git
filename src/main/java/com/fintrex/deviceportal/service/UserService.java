package com.fintrex.deviceportal.service;

import com.fintrex.deviceportal.dto.User;
import com.fintrex.deviceportal.dto.UserType;
import com.fintrex.deviceportal.dto.Screen;
import com.fintrex.deviceportal.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User validateUser(String username, String password) {
        User user = userRepository.findByUsername(username);
        if (user != null && user.getPassword().equals(password)) {
            // Password matches (using plain-text check for development simplicity)
            return user;
        }
        return null;
    }

    public User getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public List<User> getAllUsers() {
        return userRepository.findAllUsers();
    }

    public List<UserType> getAllUserTypes() {
        return userRepository.findAllUserTypes();
    }

    public List<Screen> getAllScreens() {
        return userRepository.findAllScreens();
    }

    public List<Screen> getPermittedScreens(int userTypeId) {
        return userRepository.findPermittedScreens(userTypeId);
    }

    public boolean createUser(String username, String password, String fullName, String email, int userTypeId) {
        try {
            int rows = userRepository.createUser(username, password, fullName, email, userTypeId);
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean createUserType(String name, String description) {
        try {
            int rows = userRepository.createUserType(name, description);
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public void updateUserTypePermissions(int userTypeId, List<Integer> screenIds) {
        userRepository.updateUserTypePermissions(userTypeId, screenIds);
    }

    public boolean updateUser(int id, String fullName, String email, int userTypeId, String password) {
        try {
            int rows = userRepository.updateUser(id, fullName, email, userTypeId, password);
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
