-- MySQL Workbench Forward Engineering
-- Modelo físico: Sistema de Control de Inventario y Gestión de Actividades Técnicas
-- Evidencia: GA6-220501096-AA2-EV03
-- Aprendiz: Jafer Enrique Arteaga Sossa

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema inventario_tecnico
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `inventario_tecnico`;
CREATE SCHEMA IF NOT EXISTS `inventario_tecnico` DEFAULT CHARACTER SET utf8mb4 ;
USE `inventario_tecnico` ;

-- -----------------------------------------------------
-- Table `inventario_tecnico`.`rol`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `inventario_tecnico`.`rol` ;

CREATE TABLE IF NOT EXISTS `inventario_tecnico`.`rol` (
  `id_rol` INT NOT NULL AUTO_INCREMENT,
  `nombre_rol` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`id_rol`),
  UNIQUE INDEX `uq_rol_nombre` (`nombre_rol` ASC) VISIBLE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `inventario_tecnico`.`usuario`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `inventario_tecnico`.`usuario` ;

CREATE TABLE IF NOT EXISTS `inventario_tecnico`.`usuario` (
  `id_usuario` INT NOT NULL AUTO_INCREMENT,
  `nombre_completo` VARCHAR(100) NOT NULL,
  `usuario_login` VARCHAR(50) NOT NULL,
  `contrasena` VARCHAR(255) NOT NULL,
  `id_rol` INT NOT NULL,
  `estado` VARCHAR(15) NOT NULL DEFAULT 'activo',
  PRIMARY KEY (`id_usuario`),
  UNIQUE INDEX `uq_usuario_login` (`usuario_login` ASC) VISIBLE,
  INDEX `fk_usuario_rol_idx` (`id_rol` ASC) VISIBLE,
  CONSTRAINT `ck_usuario_estado` CHECK (`estado` IN ('activo', 'inactivo')),
  CONSTRAINT `fk_usuario_rol`
    FOREIGN KEY (`id_rol`)
    REFERENCES `inventario_tecnico`.`rol` (`id_rol`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `inventario_tecnico`.`equipo`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `inventario_tecnico`.`equipo` ;

CREATE TABLE IF NOT EXISTS `inventario_tecnico`.`equipo` (
  `id_equipo` INT NOT NULL AUTO_INCREMENT,
  `codigo` VARCHAR(20) NOT NULL,
  `tipo` VARCHAR(50) NOT NULL,
  `marca` VARCHAR(50) NOT NULL,
  `serie` VARCHAR(50) NOT NULL,
  `estado` VARCHAR(20) NOT NULL DEFAULT 'disponible',
  `ubicacion` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id_equipo`),
  UNIQUE INDEX `uq_equipo_codigo` (`codigo` ASC) VISIBLE,
  UNIQUE INDEX `uq_equipo_serie` (`serie` ASC) VISIBLE,
  CONSTRAINT `ck_equipo_estado` CHECK (`estado` IN ('disponible', 'asignado', 'mantenimiento', 'baja'))
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `inventario_tecnico`.`asignacion`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `inventario_tecnico`.`asignacion` ;

CREATE TABLE IF NOT EXISTS `inventario_tecnico`.`asignacion` (
  `id_asignacion` INT NOT NULL AUTO_INCREMENT,
  `id_equipo` INT NOT NULL,
  `id_usuario` INT NOT NULL,
  `fecha_entrega` DATE NOT NULL,
  `fecha_devolucion` DATE NULL,
  PRIMARY KEY (`id_asignacion`),
  INDEX `fk_asignacion_equipo_idx` (`id_equipo` ASC) VISIBLE,
  INDEX `fk_asignacion_usuario_idx` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `ck_asignacion_fechas` CHECK (`fecha_devolucion` IS NULL OR `fecha_devolucion` >= `fecha_entrega`),
  CONSTRAINT `fk_asignacion_equipo`
    FOREIGN KEY (`id_equipo`)
    REFERENCES `inventario_tecnico`.`equipo` (`id_equipo`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_asignacion_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `inventario_tecnico`.`usuario` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `inventario_tecnico`.`actividad`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `inventario_tecnico`.`actividad` ;

CREATE TABLE IF NOT EXISTS `inventario_tecnico`.`actividad` (
  `id_actividad` INT NOT NULL AUTO_INCREMENT,
  `id_usuario` INT NOT NULL,
  `tipo_actividad` VARCHAR(30) NOT NULL,
  `fecha_inicio` DATETIME NOT NULL,
  `fecha_fin` DATETIME NULL,
  `ubicacion` VARCHAR(150) NOT NULL,
  `estado_ejecucion` VARCHAR(20) NOT NULL DEFAULT 'pendiente',
  `observaciones` VARCHAR(255) NULL,
  PRIMARY KEY (`id_actividad`),
  INDEX `fk_actividad_usuario_idx` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `ck_actividad_tipo` CHECK (`tipo_actividad` IN ('instalacion', 'mantenimiento', 'retiro')),
  CONSTRAINT `ck_actividad_estado` CHECK (`estado_ejecucion` IN ('ejecutada', 'pendiente', 'cancelada')),
  CONSTRAINT `fk_actividad_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `inventario_tecnico`.`usuario` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `inventario_tecnico`.`material`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `inventario_tecnico`.`material` ;

CREATE TABLE IF NOT EXISTS `inventario_tecnico`.`material` (
  `id_material` INT NOT NULL AUTO_INCREMENT,
  `nombre_material` VARCHAR(80) NOT NULL,
  `unidad_medida` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`id_material`),
  UNIQUE INDEX `uq_material_nombre` (`nombre_material` ASC) VISIBLE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `inventario_tecnico`.`actividad_material`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `inventario_tecnico`.`actividad_material` ;

CREATE TABLE IF NOT EXISTS `inventario_tecnico`.`actividad_material` (
  `id_actividad` INT NOT NULL,
  `id_material` INT NOT NULL,
  `cantidad` DECIMAL(8,2) NOT NULL,
  PRIMARY KEY (`id_actividad`, `id_material`),
  INDEX `fk_actmat_material_idx` (`id_material` ASC) VISIBLE,
  CONSTRAINT `ck_actmat_cantidad` CHECK (`cantidad` > 0),
  CONSTRAINT `fk_actmat_actividad`
    FOREIGN KEY (`id_actividad`)
    REFERENCES `inventario_tecnico`.`actividad` (`id_actividad`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_actmat_material`
    FOREIGN KEY (`id_material`)
    REFERENCES `inventario_tecnico`.`material` (`id_material`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `inventario_tecnico`.`evidencia`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `inventario_tecnico`.`evidencia` ;

CREATE TABLE IF NOT EXISTS `inventario_tecnico`.`evidencia` (
  `id_evidencia` INT NOT NULL AUTO_INCREMENT,
  `id_actividad` INT NOT NULL,
  `tipo_archivo` VARCHAR(20) NOT NULL,
  `ruta_archivo` VARCHAR(255) NOT NULL,
  `fecha_carga` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_evidencia`),
  INDEX `fk_evidencia_actividad_idx` (`id_actividad` ASC) VISIBLE,
  CONSTRAINT `ck_evidencia_tipo` CHECK (`tipo_archivo` IN ('foto', 'documento')),
  CONSTRAINT `fk_evidencia_actividad`
    FOREIGN KEY (`id_actividad`)
    REFERENCES `inventario_tecnico`.`actividad` (`id_actividad`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `inventario_tecnico`.`auditoria`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `inventario_tecnico`.`auditoria` ;

CREATE TABLE IF NOT EXISTS `inventario_tecnico`.`auditoria` (
  `id_auditoria` INT NOT NULL AUTO_INCREMENT,
  `id_usuario` INT NOT NULL,
  `accion` VARCHAR(50) NOT NULL,
  `tabla_afectada` VARCHAR(50) NOT NULL,
  `fecha_hora` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `detalle` VARCHAR(255) NULL,
  PRIMARY KEY (`id_auditoria`),
  INDEX `fk_auditoria_usuario_idx` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_auditoria_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `inventario_tecnico`.`usuario` (`id_usuario`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
