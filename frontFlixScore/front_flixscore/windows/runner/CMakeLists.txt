cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# --- INICIO: CORRECCIÓN DE RUNTIME ESTATICO (/MT) ---
# Establecer explícitamente el uso de la librería de tiempo de ejecución de enlace estático (/MT).
# Esto resuelve errores de símbolos sin resolver de C++ (bad_cast, __std_find, etc.)
# causados por la mezcla de /MD y /MT entre el runner y las librerías estáticas de Firebase.
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_PROFILE} /MT")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_PROFILE} /MT")
# --- FIN: CORRECCIÓN DE RUNTIME ESTATICO (/MT) ---


# Define the application target.
add_executable(${BINARY_NAME} WIN32
    "flutter_window.cpp"
    "main.cpp"
    "utils.cpp"
    "win32_window.cpp"
    "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
    "Runner.rc"
    "runner.exe.manifest"
)

# Apply the standard set of build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")

# --- INICIO: CORRECCIÓN DE ENLACE DE FIREBASE/CRT/STL ---

# 2. ENLACE EXPLÍCITO DE LIBRERÍAS DEL SISTEMA Y CRT
# Añadimos las librerías necesarias, incluyendo 'synchronization.lib' para intentar resolver
# los símbolos de concurrencia faltantes (_Thrd_sleep_for, _Cnd_timedwait_for_unchecked).
target_link_libraries(${BINARY_NAME} PRIVATE 
    "legacy_stdio_definitions.lib" 
    "Shlwapi.lib"
    "DbgHelp.lib"
    "ws2_32.lib"
    "Wldap32.lib"
    "winmm.lib"
    "Advapi32.lib"
    "ucrt.lib"         
    "LIBCMT.lib"       
    "vcruntime.lib"
    "msvcrt.lib"          # <--- AGREGADO: C Runtime (Dynamic)
    "libcpmt.lib"         # <--- AGREGADO: C++ Runtime (Static)
    "synchronization.lib"
)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
# --- FIN: CORRECCIÓN DE ENLACE DE FIREBASE/CRT/STL ---