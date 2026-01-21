part of 'bloc.dart';

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

final class ChangeThemeMode extends ThemeEvent {
  final ThemeMode themeMode;

  const ChangeThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

final class ChangeTheme extends ThemeEvent {
  final AppTheme theme;

  const ChangeTheme(this.theme);

  @override
  List<Object?> get props => [theme];
}
