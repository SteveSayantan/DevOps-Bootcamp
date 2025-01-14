### 1. **`^` (Caret)**
- **Purpose**: Matches the beginning of a string (or URI).
- **Example**: Match URIs that start with `/blog/`.
  ```nginx
  location ~ ^/blog/ {
      # Configuration
  }
  ```

### 2. **`$` (Dollar Sign)**
- **Purpose**: Matches the end of a string.
- **Example**: Match URIs that end with `.html`.
  ```nginx
  location ~ \.html$ {
      # Configuration
  }
  ```

### 3. **`.` (Dot)**
- **Purpose**: Matches any single character (except newlines).
- **Example**: This would match any single character followed by php. For example, it could match `/xphp`, `/9php`, or `/@php` .

  ```nginx
  location ~ .php$ {
      # Configuration
  }
  ```

### 4. **`.*` (Dot Asterisk)**
- **Purpose**: Matches **zero or more** of any characters.
- **Example**: Match any URI starting with `/images/` followed by any characters.
  ```nginx
  location ~ ^/images/.* {
      # Configuration
  }
  ```

### 5. **`+` (Plus)**
- **Purpose**: Matches **one or more** of the preceding character or group.
- **Example**: Match URIs that contain one or more digits (like `/user/123`).
  ```nginx
  location ~ /user/[0-9]+ {
      # Configuration
  }
  ```

### 6. **`[]` (Square Brackets)**
- **Purpose**: Matches any single character within the brackets.
- **Example**: Match any URI that contains `/file1.html` or `/file2.html` but not `/file12.html`.
  ```nginx
  location ~ /file[12]\.html$ {
      # Configuration
  }
  ```

### 7. **`()` (Parentheses)**
- **Purpose**: Groups multiple characters into a single unit.
- **Example**: Capture any file extension after `/files/`.
  ```nginx
  location ~ ^/files/(.*)\.(jpg|png|gif)$ {
      # Configuration
  }
  ```

### 8. **`|` (Pipe)**
- **Purpose**: Acts as an OR operator to match one or another option.
- **Example**: Match URIs that end with `.jpg` or `.png`.
  ```nginx
  location ~ \.(jpg|png)$ {
      # Configuration
  }
  ```

### 9. **`\d`**
- **Purpose**: Matches any single digit (0-9).
- **Example**: Match any URI that contains a number.
  ```nginx
  location ~ /id/\d+ {
      # Configuration
  }
  ```

### 10. **`\w`**
- **Purpose**: Matches any alphanumeric character or underscore.
- **Example**: Match any alphanumeric username in the URI.
  ```nginx
  location ~ ^/user/\w+$ {
      # Configuration
  }
  ```

### 11. **`?`**
- **Purpose**: Makes the preceding character optional.

- **Example**: Match URIs that start with `/blog/` or `/blog`.

  ```nginx
  location ~ ^/blog/? {
      # Configuration
  }
  ```

### 12. **`\` (Escape Character)**
- **Purpose**: Escapes special characters in regular expressions.

- **Example**: The literal period (`.`) has been escaped.
  ```nginx
  location ~ \.html$ {
      # Configuration
  }
  ```

### 13. **`{}` (Quantifiers)**
- **Purpose**: Specifies a specific number of matches.
- **Example**: Match a URI that contains exactly three digits.
  ```nginx
  location ~ /product/[0-9]{3} {
      # Configuration
  }
  ```
