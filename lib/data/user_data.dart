import '../models/user_model.dart';

class UserData {
  static final List<UserModel> _users = [
      UserModel(
        id: '001',
        name: 'Rajesh Kumar',
        nameHindi: 'राजेश कुमार',
        role: 'Supervisor',
        roleHindi: 'पर्यवेक्षक',
        initials: 'RK',
        isActive: true,
      ),
      UserModel(
        id: '002',
        name: 'Amit Singh',
        nameHindi: 'अमित सिंह',
        role: 'Worker',
        roleHindi: 'कर्मचारी',
        initials: 'AS',
        isActive: true,
      ),
      UserModel(
        id: '003',
        name: 'Mohan Gupta',
        nameHindi: 'मोहन गुप्ता',
        role: 'Manager',
        roleHindi: 'प्रबंधक',
        initials: 'MG',
        isActive: true,
      ),
      UserModel(
        id: '004',
        name: 'Suresh Kumar',
        nameHindi: 'सुरेश कुमार',
        role: 'Worker',
        roleHindi: 'कर्मचारी',
        initials: 'SK',
        isActive: true,
      ),
      UserModel(
        id: '005',
        name: 'Priya Sharma',
        nameHindi: 'प्रिया शर्मा',
        role: 'Supervisor',
        roleHindi: 'पर्यवेक्षक',
        initials: 'PS',
        isActive: true,
      ),
      UserModel(
        id: '006',
        name: 'Ravi Verma',
        nameHindi: 'रवि वर्मा',
        role: 'Worker',
        roleHindi: 'कर्मचारी',
        initials: 'RV',
        isActive: false,
      ),
  ];

  // Store current user phone for filtering self from lists
  static String? _currentUserPhone;
  
  static void setCurrentUserPhone(String phone) {
    _currentUserPhone = phone;
  }
  
  static String? get currentUserPhone => _currentUserPhone;

  // Store current user role for permission checks
  static String? _currentUserRole;
  
  static void setCurrentUserRole(String role) {
    _currentUserRole = role;
  }
  
  static String? get currentUserRole => _currentUserRole;

  static List<UserModel> getUsers() {
    return List<UserModel>.unmodifiable(_users);
  }

  static int getTotalUsers() {
    return _users.length;
  }

  static int getActiveWorkers() {
    return _users.where((user) => user.isActive && user.role == 'Worker').length;
  }

  static List<UserModel> getUsersByRole(String role) {
    if (role == 'All') return getUsers();
    return _users.where((user) => user.role == role).toList();
  }

  static void addUser(UserModel user) {
    _users.insert(0, user);
  }

  static void updateUser(UserModel updated) {
    final index = _users.indexWhere((u) => u.id == updated.id);
    if (index != -1) {
      _users[index] = updated;
    }
  }

  static void removeUser(String id) {
    _users.removeWhere((u) => u.id == id);
  }

  static void clear() {
    _users.clear();
  }
}
