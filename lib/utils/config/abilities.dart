import 'config.dart';

List<String> getComputedAbilities(List<String> userRoles) {
  Set<String> abilities = {};
  if (userRoles.contains('users')) {
    abilities.addAll(configMap.roles.users.abilities);
  }
  if (userRoles.contains('companies')) {
    abilities.addAll(configMap.roles.companies.abilities);
  }
  if (userRoles.contains('admins')) {
    abilities.addAll(configMap.roles.admins.abilities);
  }
  return abilities.toList();
}
