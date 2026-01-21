import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/src/theme/form_bloc_theme.dart';
import 'package:flutter_form_bloc/src/utils/field_bloc_builder_control_affinity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormTheme', () {
    test('can be const constructed with defaults', () {
      const theme = FormTheme();
      expect(theme, isA<FormTheme>());
    });

    test('defaults textStyle to null', () {
      const theme = FormTheme();
      expect(theme.textStyle, isNull);
    });

    test('defaults textColor to null', () {
      const theme = FormTheme();
      expect(theme.textColor, isNull);
    });

    test('defaults decorationTheme to null', () {
      const theme = FormTheme();
      expect(theme.decorationTheme, isNull);
    });

    test('defaults padding to null', () {
      const theme = FormTheme();
      expect(theme.padding, isNull);
    });

    test('has default sub-themes', () {
      const theme = FormTheme();

      expect(theme.checkboxTheme, isA<CheckboxFieldTheme>());
      expect(theme.choiceChipTheme, isA<ChoiceChipFieldTheme>());
      expect(theme.filterChipTheme, isA<FilterChipFieldTheme>());
      expect(theme.dateTimeTheme, isA<DateTimeFieldTheme>());
      expect(theme.dropdownTheme, isA<DropdownFieldTheme>());
      expect(theme.sliderTheme, isA<SliderFieldTheme>());
      expect(theme.switchTheme, isA<SwitchFieldTheme>());
      expect(theme.radioTheme, isA<RadioFieldTheme>());
      expect(theme.textTheme, isA<TextFieldTheme>());
    });

    test('defaultPadding is symmetric vertical 8.0', () {
      expect(
        FormTheme.defaultPadding,
        equals(const EdgeInsets.symmetric(vertical: 8.0)),
      );
    });

    group('copyWith', () {
      test('returns new instance with no changes when no args', () {
        const original = FormTheme();
        final copied = original.copyWith();

        expect(copied.textStyle, isNull);
        expect(copied.textColor, isNull);
        expect(copied.decorationTheme, isNull);
        expect(copied.padding, isNull);
      });

      test('updates textStyle', () {
        const original = FormTheme();
        const textStyle = TextStyle(fontSize: 20);
        final copied = original.copyWith(textStyle: textStyle);

        expect(copied.textStyle, equals(textStyle));
      });

      test('updates padding', () {
        const original = FormTheme();
        const padding = EdgeInsets.all(16);
        final copied = original.copyWith(padding: padding);

        expect(copied.padding, equals(padding));
      });

      test('updates checkboxTheme', () {
        const original = FormTheme();
        const checkboxTheme = CheckboxFieldTheme(canTapItemTile: true);
        final copied = original.copyWith(checkboxTheme: checkboxTheme);

        expect(copied.checkboxTheme.canTapItemTile, isTrue);
      });
    });

    group('toString', () {
      test('includes class name', () {
        const theme = FormTheme();
        final str = theme.toString();

        expect(str, contains('FormTheme'));
      });
    });

    group('props', () {
      test('includes all relevant fields', () {
        const theme = FormTheme();
        final props = theme.props;

        expect(props.length, greaterThan(5));
      });
    });
  });

  group('CheckboxFieldTheme', () {
    test('can be const constructed with defaults', () {
      const theme = CheckboxFieldTheme();
      expect(theme, isA<CheckboxFieldTheme>());
    });

    test('defaults canTapItemTile to false', () {
      const theme = CheckboxFieldTheme();
      expect(theme.canTapItemTile, isFalse);
    });

    test('defaults checkboxTheme to null', () {
      const theme = CheckboxFieldTheme();
      expect(theme.checkboxTheme, isNull);
    });

    test('defaults controlAffinity to null', () {
      const theme = CheckboxFieldTheme();
      expect(theme.controlAffinity, isNull);
    });

    test('can set canTapItemTile to true', () {
      const theme = CheckboxFieldTheme(canTapItemTile: true);
      expect(theme.canTapItemTile, isTrue);
    });

    test('can set controlAffinity', () {
      const theme = CheckboxFieldTheme(
        controlAffinity: FieldBlocBuilderControlAffinity.trailing,
      );
      expect(
        theme.controlAffinity,
        equals(FieldBlocBuilderControlAffinity.trailing),
      );
    });

    group('copyWith', () {
      test('updates canTapItemTile', () {
        const original = CheckboxFieldTheme();
        final copied = original.copyWith(canTapItemTile: true);

        expect(copied.canTapItemTile, isTrue);
      });

      test('updates controlAffinity', () {
        const original = CheckboxFieldTheme();
        final copied = original.copyWith(
          controlAffinity: FieldBlocBuilderControlAffinity.leading,
        );

        expect(
          copied.controlAffinity,
          equals(FieldBlocBuilderControlAffinity.leading),
        );
      });
    });
  });

  group('WrapChipFieldTheme', () {
    test('can be const constructed with defaults', () {
      const theme = WrapChipFieldTheme();
      expect(theme, isA<WrapChipFieldTheme>());
    });

    test('defaults spacing to null', () {
      const theme = WrapChipFieldTheme();
      expect(theme.spacing, isNull);
    });

    test('defaults runSpacing to null', () {
      const theme = WrapChipFieldTheme();
      expect(theme.runSpacing, isNull);
    });

    test('can set custom values', () {
      const theme = WrapChipFieldTheme(spacing: 16, runSpacing: 8);
      expect(theme.spacing, equals(16));
      expect(theme.runSpacing, equals(8));
    });

    group('copyWith', () {
      test('updates spacing', () {
        const original = WrapChipFieldTheme();
        final copied = original.copyWith(spacing: 12);

        expect(copied.spacing, equals(12));
      });

      test('updates runSpacing', () {
        const original = WrapChipFieldTheme();
        final copied = original.copyWith(runSpacing: 10);

        expect(copied.runSpacing, equals(10));
      });
    });

    group('equality', () {
      test('equal instances are equal', () {
        const theme1 = WrapChipFieldTheme(spacing: 8);
        const theme2 = WrapChipFieldTheme(spacing: 8);

        expect(theme1, equals(theme2));
      });

      test('different instances are not equal', () {
        const theme1 = WrapChipFieldTheme(spacing: 8);
        const theme2 = WrapChipFieldTheme(spacing: 16);

        expect(theme1, isNot(equals(theme2)));
      });
    });
  });

  group('ChoiceChipFieldTheme', () {
    test('can be const constructed', () {
      const theme = ChoiceChipFieldTheme();
      expect(theme, isA<ChoiceChipFieldTheme>());
    });

    test('defaults chipTheme to null', () {
      const theme = ChoiceChipFieldTheme();
      expect(theme.chipTheme, isNull);
    });

    test('has default wrapTheme', () {
      const theme = ChoiceChipFieldTheme();
      expect(theme.wrapTheme, isA<WrapChipFieldTheme>());
    });

    group('copyWith', () {
      test('updates wrapTheme', () {
        const original = ChoiceChipFieldTheme();
        final copied = original.copyWith(
          wrapTheme: const WrapChipFieldTheme(spacing: 20),
        );

        expect(copied.wrapTheme.spacing, equals(20));
      });
    });
  });

  group('FilterChipFieldTheme', () {
    test('can be const constructed', () {
      const theme = FilterChipFieldTheme();
      expect(theme, isA<FilterChipFieldTheme>());
    });

    test('defaults chipTheme to null', () {
      const theme = FilterChipFieldTheme();
      expect(theme.chipTheme, isNull);
    });

    test('has default wrapTheme', () {
      const theme = FilterChipFieldTheme();
      expect(theme.wrapTheme, isA<WrapChipFieldTheme>());
    });
  });

  group('DateTimeFieldTheme', () {
    test('can be const constructed', () {
      const theme = DateTimeFieldTheme();
      expect(theme, isA<DateTimeFieldTheme>());
    });

    test('defaults textAlign to null', () {
      const theme = DateTimeFieldTheme();
      expect(theme.textAlign, isNull);
    });

    test('defaults showClearIcon to null', () {
      const theme = DateTimeFieldTheme();
      expect(theme.showClearIcon, isNull);
    });

    group('copyWith', () {
      test('updates textAlign', () {
        const original = DateTimeFieldTheme();
        final copied = original.copyWith(textAlign: TextAlign.center);

        expect(copied.textAlign, equals(TextAlign.center));
      });

      test('updates showClearIcon', () {
        const original = DateTimeFieldTheme();
        final copied = original.copyWith(showClearIcon: true);

        expect(copied.showClearIcon, isTrue);
      });
    });
  });

  group('DropdownFieldTheme', () {
    test('can be const constructed', () {
      const theme = DropdownFieldTheme();
      expect(theme, isA<DropdownFieldTheme>());
    });

    test('defaults textOverflow to null', () {
      const theme = DropdownFieldTheme();
      expect(theme.textOverflow, isNull);
    });

    test('defaults maxLines to null', () {
      const theme = DropdownFieldTheme();
      expect(theme.maxLines, isNull);
    });

    test('defaults moreIcon to null', () {
      const theme = DropdownFieldTheme();
      expect(theme.moreIcon, isNull);
    });

    group('copyWith', () {
      test('updates textOverflow', () {
        const original = DropdownFieldTheme();
        final copied = original.copyWith(textOverflow: TextOverflow.fade);

        expect(copied.textOverflow, equals(TextOverflow.fade));
      });

      test('updates maxLines', () {
        const original = DropdownFieldTheme();
        final copied = original.copyWith(maxLines: 3);

        expect(copied.maxLines, equals(3));
      });
    });
  });

  group('SliderFieldTheme', () {
    test('can be const constructed', () {
      const theme = SliderFieldTheme();
      expect(theme, isA<SliderFieldTheme>());
    });

    test('defaults sliderTheme to null', () {
      const theme = SliderFieldTheme();
      expect(theme.sliderTheme, isNull);
    });

    group('props', () {
      test('contains sliderTheme', () {
        const theme = SliderFieldTheme();
        expect(theme.props, contains(null)); // sliderTheme is null
      });
    });
  });

  group('SwitchFieldTheme', () {
    test('can be const constructed', () {
      const theme = SwitchFieldTheme();
      expect(theme, isA<SwitchFieldTheme>());
    });

    test('defaults switchTheme to null', () {
      const theme = SwitchFieldTheme();
      expect(theme.switchTheme, isNull);
    });

    test('defaults controlAffinity to null', () {
      const theme = SwitchFieldTheme();
      expect(theme.controlAffinity, isNull);
    });

    group('copyWith', () {
      test('updates controlAffinity', () {
        const original = SwitchFieldTheme();
        final copied = original.copyWith(
          controlAffinity: FieldBlocBuilderControlAffinity.leading,
        );

        expect(
          copied.controlAffinity,
          equals(FieldBlocBuilderControlAffinity.leading),
        );
      });
    });
  });

  group('RadioFieldTheme', () {
    test('can be const constructed', () {
      const theme = RadioFieldTheme();
      expect(theme, isA<RadioFieldTheme>());
    });

    test('defaults radioTheme to null', () {
      const theme = RadioFieldTheme();
      expect(theme.radioTheme, isNull);
    });

    test('defaults canTapItemTile to false', () {
      const theme = RadioFieldTheme();
      expect(theme.canTapItemTile, isFalse);
    });

    test('defaults canDeselect to true', () {
      const theme = RadioFieldTheme();
      expect(theme.canDeselect, isTrue);
    });

    group('copyWith', () {
      test('updates canTapItemTile', () {
        const original = RadioFieldTheme();
        final copied = original.copyWith(canTapItemTile: true);

        expect(copied.canTapItemTile, isTrue);
      });

      test('updates canDeselect', () {
        const original = RadioFieldTheme();
        final copied = original.copyWith(canDeselect: false);

        expect(copied.canDeselect, isFalse);
      });
    });
  });

  group('TextFieldTheme', () {
    test('can be const constructed', () {
      const theme = TextFieldTheme();
      expect(theme, isA<TextFieldTheme>());
    });

    test('defaults textAlign to null', () {
      const theme = TextFieldTheme();
      expect(theme.textAlign, isNull);
    });

    test('defaults suggestionsTextStyle to null', () {
      const theme = TextFieldTheme();
      expect(theme.suggestionsTextStyle, isNull);
    });

    group('copyWith', () {
      test('updates textAlign', () {
        const original = TextFieldTheme();
        final copied = original.copyWith(textAlign: TextAlign.right);

        expect(copied.textAlign, equals(TextAlign.right));
      });

      test('updates suggestionsTextStyle', () {
        const original = TextFieldTheme();
        const style = TextStyle(color: Colors.red);
        final copied = original.copyWith(suggestionsTextStyle: style);

        expect(copied.suggestionsTextStyle, equals(style));
      });
    });
  });
}
