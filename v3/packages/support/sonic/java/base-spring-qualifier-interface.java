{{_expr_:substitute(get(g:, 'sonic_license_header', ''), 'FILE_NAME', '{{_name_}}.java', 'g')}}

{{_lang_util_:package}}

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Inherited;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import org.springframework.beans.factory.annotation.Qualifier;

@Target({ElementType.FIELD, ElementType.PARAMETER, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Inherited
@Qualifier
public @interface {{_expr_:substitute('{{_name_}}', '\w\+', '\u\0', '')}} {
  {{_cursor_}}
}
